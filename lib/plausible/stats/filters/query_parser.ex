defmodule Plausible.Stats.Filters.QueryParser do
  @moduledoc false

  alias Plausible.Stats.TableDecider
  alias Plausible.Stats.Filters
  alias Plausible.Stats.Query

  def parse(site, params, now \\ nil) when is_map(params) do
    with {:ok, metrics} <- parse_metrics(Map.get(params, "metrics", [])),
         {:ok, filters} <- parse_filters(Map.get(params, "filters", [])),
         {:ok, date_range} <-
           parse_date_range(site, Map.get(params, "date_range"), now || today(site)),
         {:ok, dimensions} <- parse_dimensions(Map.get(params, "dimensions", [])),
         {:ok, order_by} <- parse_order_by(Map.get(params, "order_by")),
         {:ok, include} <- parse_include(Map.get(params, "include", %{})),
         preloaded_goals <- preload_goals_if_needed(site, filters, dimensions),
         query = %{
           metrics: metrics,
           filters: filters,
           date_range: date_range,
           dimensions: dimensions,
           order_by: order_by,
           timezone: site.timezone,
           imported_data_requested: Map.get(include, :imports, false),
           preloaded_goals: preloaded_goals
         },
         :ok <- validate_order_by(query),
         :ok <- validate_goal_filters(query),
         :ok <- validate_custom_props_access(site, query),
         :ok <- validate_metrics(query) do
      {:ok, query}
    end
  end

  defp parse_metrics([]), do: {:error, "No valid metrics passed"}

  defp parse_metrics(metrics) when is_list(metrics) do
    if length(metrics) == length(Enum.uniq(metrics)) do
      parse_list(metrics, &parse_metric/1)
    else
      {:error, "Metrics cannot be queried multiple times"}
    end
  end

  defp parse_metrics(_invalid_metrics), do: {:error, "Invalid metrics passed"}

  defp parse_metric("time_on_page"), do: {:ok, :time_on_page}
  defp parse_metric("conversion_rate"), do: {:ok, :conversion_rate}
  defp parse_metric("group_conversion_rate"), do: {:ok, :group_conversion_rate}
  defp parse_metric("visitors"), do: {:ok, :visitors}
  defp parse_metric("pageviews"), do: {:ok, :pageviews}
  defp parse_metric("events"), do: {:ok, :events}
  defp parse_metric("visits"), do: {:ok, :visits}
  defp parse_metric("bounce_rate"), do: {:ok, :bounce_rate}
  defp parse_metric("visit_duration"), do: {:ok, :visit_duration}
  defp parse_metric("views_per_visit"), do: {:ok, :views_per_visit}
  defp parse_metric(unknown_metric), do: {:error, "Unknown metric '#{inspect(unknown_metric)}'"}

  def parse_filters(filters) when is_list(filters) do
    parse_list(filters, &parse_filter/1)
  end

  def parse_filters(_invalid_metrics), do: {:error, "Invalid filters passed"}

  defp parse_filter(filter) do
    with {:ok, operator} <- parse_operator(filter),
         {:ok, filter_key} <- parse_filter_key(filter),
         {:ok, rest} <- parse_filter_rest(operator, filter) do
      {:ok, [operator, filter_key | rest]}
    end
  end

  defp parse_operator(["is" | _rest]), do: {:ok, :is}
  defp parse_operator(["is_not" | _rest]), do: {:ok, :is_not}
  defp parse_operator(["matches" | _rest]), do: {:ok, :matches}
  defp parse_operator(["does_not_match" | _rest]), do: {:ok, :does_not_match}
  defp parse_operator(["contains" | _rest]), do: {:ok, :contains}
  defp parse_operator(["does_not_contain" | _rest]), do: {:ok, :does_not_contain}
  defp parse_operator(filter), do: {:error, "Unknown operator for filter '#{inspect(filter)}'"}

  defp parse_filter_key([_operator, filter_key | _rest] = filter) do
    parse_filter_key_string(filter_key, "Invalid filter '#{inspect(filter)}")
  end

  defp parse_filter_key(filter), do: {:error, "Invalid filter '#{inspect(filter)}'"}

  defp parse_filter_rest(operator, filter)
       when operator in [:is, :is_not, :matches, :does_not_match, :contains, :does_not_contain],
       do: parse_clauses_list(filter)

  defp parse_clauses_list([_operation, filter_key, list] = filter) when is_list(list) do
    all_strings? = Enum.all?(list, &is_bitstring/1)

    cond do
      filter_key == "event:goal" && all_strings? -> {:ok, [Filters.Utils.wrap_goal_value(list)]}
      filter_key != "event:goal" && all_strings? -> {:ok, [list]}
      true -> {:error, "Invalid filter '#{inspect(filter)}'"}
    end
  end

  defp parse_clauses_list(filter), do: {:error, "Invalid filter '#{inspect(filter)}'"}

  defp parse_date_range(_site, "day", date) do
    {:ok, Date.range(date, date)}
  end

  defp parse_date_range(_site, "7d", last) do
    first = last |> Timex.shift(days: -6)
    {:ok, Date.range(first, last)}
  end

  defp parse_date_range(_site, "30d", last) do
    first = last |> Timex.shift(days: -30)
    {:ok, Date.range(first, last)}
  end

  defp parse_date_range(_site, "month", today) do
    last = today |> Timex.end_of_month()
    first = last |> Timex.beginning_of_month()
    {:ok, Date.range(first, last)}
  end

  defp parse_date_range(_site, "6mo", today) do
    last = today |> Timex.end_of_month()

    first =
      last
      |> Timex.shift(months: -5)
      |> Timex.beginning_of_month()

    {:ok, Date.range(first, last)}
  end

  defp parse_date_range(_site, "12mo", today) do
    last = today |> Timex.end_of_month()

    first =
      last
      |> Timex.shift(months: -11)
      |> Timex.beginning_of_month()

    {:ok, Date.range(first, last)}
  end

  defp parse_date_range(_site, "year", today) do
    last = today |> Timex.end_of_year()
    first = last |> Timex.beginning_of_year()
    {:ok, Date.range(first, last)}
  end

  defp parse_date_range(site, "all", today) do
    start_date = Plausible.Sites.stats_start_date(site) || today

    {:ok, Date.range(start_date, today)}
  end

  defp parse_date_range(_site, [from_date_string, to_date_string], _date)
       when is_bitstring(from_date_string) and is_bitstring(to_date_string) do
    with {:ok, from_date} <- Date.from_iso8601(from_date_string),
         {:ok, to_date} <- Date.from_iso8601(to_date_string) do
      {:ok, Date.range(from_date, to_date)}
    else
      _ -> {:error, "Invalid date_range '#{inspect([from_date_string, to_date_string])}'"}
    end
  end

  defp parse_date_range(site, %{"period" => period, "to_date" => to_date_string}, _date)
       when is_bitstring(period) and is_bitstring(to_date_string) do
    with {:ok, to_date} <- Date.from_iso8601(to_date_string) do
      parse_date_range(site, period, to_date)
    end
  end

  defp parse_date_range(_site, unknown, _),
    do: {:error, "Invalid date_range '#{inspect(unknown)}'"}

  defp today(site), do: DateTime.now!(site.timezone) |> DateTime.to_date()

  defp parse_dimensions(dimensions) when is_list(dimensions) do
    if length(dimensions) == length(Enum.uniq(dimensions)) do
      parse_list(
        dimensions,
        &parse_dimension_entry(&1, "Invalid dimensions '#{inspect(dimensions)}'")
      )
    else
      {:error, "Some dimensions are listed multiple times"}
    end
  end

  defp parse_dimensions(dimensions), do: {:error, "Invalid dimensions '#{inspect(dimensions)}'"}

  defp parse_order_by(order_by) when is_list(order_by) do
    parse_list(order_by, &parse_order_by_entry/1)
  end

  defp parse_order_by(nil), do: {:ok, nil}
  defp parse_order_by(order_by), do: {:error, "Invalid order_by '#{inspect(order_by)}'"}

  defp parse_order_by_entry(entry) do
    with {:ok, value} <- parse_metric_or_dimension(entry),
         {:ok, order_direction} <- parse_order_direction(entry) do
      {:ok, {value, order_direction}}
    end
  end

  defp parse_dimension_entry(key, error_message) do
    case {
      parse_time(key),
      parse_filter_key_string(key)
    } do
      {{:ok, time}, _} -> {:ok, time}
      {_, {:ok, filter_key}} -> {:ok, filter_key}
      _ -> {:error, error_message}
    end
  end

  defp parse_metric_or_dimension([value, _] = entry) do
    case {
      parse_time(value),
      parse_metric(value),
      parse_filter_key_string(value)
    } do
      {{:ok, time}, _, _} -> {:ok, time}
      {_, {:ok, metric}, _} -> {:ok, metric}
      {_, _, {:ok, dimension}} -> {:ok, dimension}
      _ -> {:error, "Invalid order_by entry '#{inspect(entry)}'"}
    end
  end

  defp parse_time("time"), do: {:ok, "time"}
  defp parse_time("time:hour"), do: {:ok, "time:hour"}
  defp parse_time("time:day"), do: {:ok, "time:day"}
  defp parse_time("time:month"), do: {:ok, "time:month"}
  defp parse_time(_), do: :error

  defp parse_order_direction([_, "asc"]), do: {:ok, :asc}
  defp parse_order_direction([_, "desc"]), do: {:ok, :desc}
  defp parse_order_direction(entry), do: {:error, "Invalid order_by entry '#{inspect(entry)}'"}

  defp parse_include(%{"imports" => value}) when is_boolean(value), do: {:ok, %{imports: value}}
  defp parse_include(%{}), do: {:ok, %{}}
  defp parse_include(include), do: {:error, "Invalid include passed '#{inspect(include)}'"}

  defp parse_filter_key_string(filter_key, error_message \\ "") do
    case filter_key do
      "event:props:" <> property_name ->
        if String.length(property_name) > 0 do
          {:ok, filter_key}
        else
          {:error, error_message}
        end

      "event:" <> key ->
        if key in Filters.event_props() do
          {:ok, filter_key}
        else
          {:error, error_message}
        end

      "visit:" <> key ->
        if key in Filters.visit_props() do
          {:ok, filter_key}
        else
          {:error, error_message}
        end

      _ ->
        {:error, error_message}
    end
  end

  defp validate_order_by(query) do
    if query.order_by do
      valid_values = query.metrics ++ query.dimensions

      invalid_entry =
        Enum.find(query.order_by, fn {value, _direction} ->
          not Enum.member?(valid_values, value)
        end)

      case invalid_entry do
        nil ->
          :ok

        _ ->
          {:error,
           "Invalid order_by entry '#{inspect(invalid_entry)}'. Entry is not a queried metric or dimension"}
      end
    else
      :ok
    end
  end

  defp preload_goals_if_needed(site, filters, dimensions) do
    goal_filters? =
      Enum.any?(filters, fn [_, filter_key | _rest] -> filter_key == "event:goal" end)

    if goal_filters? or Enum.member?(dimensions, "event:goal") do
      Filters.Utils.load_goals(site)
    else
      []
    end
  end

  defp validate_goal_filters(query) do
    goal_filter_clauses =
      Enum.flat_map(query.filters, fn
        [_operation, "event:goal", clauses] -> clauses
        _ -> []
      end)

    if length(goal_filter_clauses) > 0 do
      validate_list(goal_filter_clauses, &validate_goal_filter(&1, query.preloaded_goals))
    else
      :ok
    end
  end

  defp validate_goal_filter(clause, configured_goals) do
    if Enum.member?(configured_goals, clause) do
      :ok
    else
      {:error,
       "The goal `#{Filters.Utils.unwrap_goal_value(clause)}` is not configured for this site. Find out how to configure goals here: https://plausible.io/docs/stats-api#filtering-by-goals"}
    end
  end

  defp validate_custom_props_access(site, query) do
    allowed_props = Plausible.Props.allowed_for(site, bypass_setup?: true)

    validate_custom_props_access(site, query, allowed_props)
  end

  defp validate_custom_props_access(_site, _query, :all), do: :ok

  defp validate_custom_props_access(_site, query, allowed_props) do
    valid? =
      query.filters
      |> Enum.map(fn [_operation, filter_key | _rest] -> filter_key end)
      |> Enum.concat(query.dimensions)
      |> Enum.all?(fn
        "event:props:" <> prop -> prop in allowed_props
        _ -> true
      end)

    if valid? do
      :ok
    else
      {:error, "The owner of this site does not have access to the custom properties feature"}
    end
  end

  defp validate_metrics(query) do
    with :ok <- validate_list(query.metrics, &validate_metric(&1, query)) do
      validate_no_metrics_filters_conflict(query)
    end
  end

  defp validate_metric(metric, query) when metric in [:conversion_rate, :group_conversion_rate] do
    if Enum.member?(query.dimensions, "event:goal") or
         not is_nil(Query.get_filter(query, "event:goal")) do
      :ok
    else
      {:error, "Metric `#{metric}` can only be queried with event:goal filters or dimensions"}
    end
  end

  defp validate_metric(:views_per_visit = metric, query) do
    cond do
      not is_nil(Query.get_filter(query, "event:page")) ->
        {:error, "Metric `#{metric}` cannot be queried with a filter on `event:page`"}

      length(query.dimensions) > 0 ->
        {:error, "Metric `#{metric}` cannot be queried with `dimensions`"}

      true ->
        :ok
    end
  end

  defp validate_metric(_, _), do: :ok

  defp validate_no_metrics_filters_conflict(query) do
    {_event_metrics, sessions_metrics, _other_metrics} =
      TableDecider.partition_metrics(query.metrics, query)

    if Enum.empty?(sessions_metrics) or not TableDecider.event_dimensions?(query) do
      :ok
    else
      {:error,
       "Session metric(s) `#{sessions_metrics |> Enum.join(", ")}` cannot be queried along with event dimensions"}
    end
  end

  defp parse_list(list, parser_function) do
    Enum.reduce_while(list, {:ok, []}, fn value, {:ok, results} ->
      case parser_function.(value) do
        {:ok, result} -> {:cont, {:ok, results ++ [result]}}
        {:error, _} = error -> {:halt, error}
      end
    end)
  end

  defp validate_list(list, parser_function) do
    Enum.reduce_while(list, :ok, fn value, :ok ->
      case parser_function.(value) do
        :ok -> {:cont, :ok}
        {:error, _} = error -> {:halt, error}
      end
    end)
  end
end
