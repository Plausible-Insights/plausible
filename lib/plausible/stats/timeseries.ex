defmodule Plausible.Stats.Timeseries do
  @moduledoc """
  Builds timeseries results for v1 of our stats API and dashboards.

  Avoid adding new logic here - update QueryBuilder etc instead.
  """

  use Plausible
  use Plausible.ClickhouseRepo
  alias Plausible.Stats.{Comparisons, Query, QueryRunner, Time}

  @time_dimension %{
    "month" => "time:month",
    "week" => "time:week",
    "day" => "time:day",
    "hour" => "time:hour",
    "minute" => "time:minute"
  }

  def timeseries(site, query, metrics) do
    {currency, metrics} =
      on_ee do
        Plausible.Stats.Goal.Revenue.get_revenue_tracking_currency(site, query, metrics)
      else
        {nil, metrics}
      end

    query =
      Query.set(
        query,
        metrics: transform_metrics(metrics, %{conversion_rate: :group_conversion_rate}),
        dimensions: [time_dimension(query)],
        order_by: [{time_dimension(query), :asc}],
        v2: true
      )

    comparison_query =
      if(query.include.comparisons,
        do: Comparisons.compare(query, query.include.comparisons),
        else: nil
      )

    query_result = QueryRunner.run(site, query)

    {
      build_result(query_result, query, currency, fn entry -> entry end),
      build_result(query_result, comparison_query, currency, fn entry -> entry.comparison end),
      query_result.meta
    }
  end

  defp time_dimension(query), do: Map.fetch!(@time_dimension, query.interval)

  defp build_result(query_result, %Query{} = query, currency, extract_entry) do
    query_result.results
    |> Enum.map(&extract_entry.(&1))
    |> Enum.map(fn %{dimensions: [time_dimension_value], metrics: metrics} ->
      metrics_map = Enum.zip(query.metrics, metrics) |> Map.new()

      {
        time_dimension_value,
        Map.put(metrics_map, :date, time_dimension_value)
      }
    end)
    |> Map.new()
    |> add_labels(query, currency)
  end

  defp build_result(_, _, _, _), do: nil

  defp add_labels(results_map, query, currency) do
    query
    |> Time.time_labels()
    |> Enum.map(fn key ->
      Map.get(
        results_map,
        key,
        empty_row(key, query.metrics)
      )
      |> cast_revenue_metrics_to_money(currency)
    end)
    |> transform_realtime_labels(query)
    |> transform_keys(%{group_conversion_rate: :conversion_rate})
  end

  defp empty_row(date, metrics) do
    Enum.reduce(metrics, %{date: date}, fn metric, row ->
      case metric do
        :pageviews -> Map.merge(row, %{pageviews: 0})
        :events -> Map.merge(row, %{events: 0})
        :visitors -> Map.merge(row, %{visitors: 0})
        :visits -> Map.merge(row, %{visits: 0})
        :views_per_visit -> Map.merge(row, %{views_per_visit: 0.0})
        :conversion_rate -> Map.merge(row, %{conversion_rate: 0.0})
        :group_conversion_rate -> Map.merge(row, %{group_conversion_rate: 0.0})
        :bounce_rate -> Map.merge(row, %{bounce_rate: 0.0})
        :visit_duration -> Map.merge(row, %{visit_duration: nil})
        :average_revenue -> Map.merge(row, %{average_revenue: nil})
        :total_revenue -> Map.merge(row, %{total_revenue: nil})
      end
    end)
  end

  defp transform_metrics(metrics, to_replace) do
    Enum.map(metrics, &Map.get(to_replace, &1, &1))
  end

  defp transform_keys(results, keys_to_replace) do
    Enum.map(results, fn map ->
      Enum.map(map, fn {key, val} ->
        {Map.get(keys_to_replace, key, key), val}
      end)
      |> Enum.into(%{})
    end)
  end

  defp transform_realtime_labels(results, %Query{period: "30m"}) do
    Enum.with_index(results)
    |> Enum.map(fn {entry, index} -> %{entry | date: -30 + index} end)
  end

  defp transform_realtime_labels(results, _query), do: results

  on_ee do
    defp cast_revenue_metrics_to_money(results, revenue_goals) do
      Plausible.Stats.Goal.Revenue.cast_revenue_metrics_to_money(results, revenue_goals)
    end
  else
    defp cast_revenue_metrics_to_money(results, _revenue_goals), do: results
  end
end
