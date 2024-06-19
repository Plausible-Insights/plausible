defmodule Plausible.Stats.QueryOptimizer do
  @moduledoc """
    This module manipulates an existing query, updating it according to business logic.

    For example, it:
    1. Figures out what the right granularity to group by time is
    2. Adds a missing order_by clause to a query
    3. Updating "time" dimension in order_by to the right granularity
  """

  alias Plausible.Stats.Query

  def optimize(query) do
    Enum.reduce(pipeline(), query, fn step, acc -> step.(acc) end)
  end

  defp pipeline() do
    [
      &update_group_by_time/1,
      &add_missing_order_by/1,
      &update_time_in_order_by/1,
      &extend_hostname_filters_to_visit/1
    ]
  end

  defp add_missing_order_by(%Query{order_by: nil} = query) do
    order_by =
      case time_dimension(query) do
        nil -> [{hd(query.metrics), :desc}]
        time_dimension -> [{time_dimension, :asc}, {hd(query.metrics), :desc}]
      end

    %Query{query | order_by: order_by}
  end

  defp add_missing_order_by(query), do: query

  defp update_group_by_time(
         %Query{
           date_range: %Date.Range{first: first, last: last}
         } = query
       ) do
    dimensions =
      query.dimensions
      |> Enum.map(fn
        "time" -> resolve_time_dimension(first, last)
        entry -> entry
      end)

    %Query{query | dimensions: dimensions}
  end

  defp update_group_by_time(query), do: query

  defp resolve_time_dimension(first, last) do
    cond do
      Timex.diff(last, first, :hours) <= 48 -> "time:hour"
      Timex.diff(last, first, :days) <= 40 -> "time:day"
      true -> "time:month"
    end
  end

  defp update_time_in_order_by(query) do
    order_by =
      query.order_by
      |> Enum.map(fn
        {"time", direction} -> {time_dimension(query), direction}
        entry -> entry
      end)

    %Query{query | order_by: order_by}
  end

  @dimensions_hostname_map %{
    "visit:source" => "visit:entry_page_hostname",
    "visit:entry_page" => "visit:entry_page_hostname",
    "visit:utm_medium" => "visit:entry_page_hostname",
    "visit:utm_source" => "visit:entry_page_hostname",
    "visit:utm_campaign" => "visit:entry_page_hostname",
    "visit:utm_content" => "visit:entry_page_hostname",
    "visit:utm_term" => "visit:entry_page_hostname",
    "visit:referrer" => "visit:entry_page_hostname",
    "visit:exit_page" => "visit:exit_page_hostname"
  }

  # To avoid showing referrers across hostnames when event:hostname
  # filter is present for breakdowns, add entry/exit page hostname
  # filters
  defp extend_hostname_filters_to_visit(query) do
    hostname_filters =
      query.filters
      |> Enum.filter(fn [_operation, filter_key | _rest] -> filter_key == "event:hostname" end)

    if length(hostname_filters) > 0 do
      extra_filters =
        query.dimensions
        |> Enum.flat_map(&hostname_filters_for_dimension(&1, hostname_filters))

      %Query{query | filters: query.filters ++ extra_filters}
    else
      query
    end
  end

  defp hostname_filters_for_dimension(dimension, hostname_filters) do
    if Map.has_key?(@dimensions_hostname_map, dimension) do
      filter_key = Map.get(@dimensions_hostname_map, dimension)

      hostname_filters
      |> Enum.map(fn [operation, _filter_key | rest] -> [operation, filter_key | rest] end)
    else
      []
    end
  end

  defp time_dimension(query) do
    Enum.find(query.dimensions, &String.starts_with?(&1, "time"))
  end
end
