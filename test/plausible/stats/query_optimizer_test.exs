defmodule Plausible.Stats.IntervalTest do
  use Plausible.DataCase, async: true

  alias Plausible.Stats.{Query, QueryOptimizer}

  @default_params %{metrics: [:visitors]}

  def perform(params) do
    params = Map.merge(@default_params, params) |> Map.to_list()
    struct!(Query, params) |> QueryOptimizer.optimize()
  end

  describe "add_missing_order_by" do
    test "does nothing if order_by passed" do
      assert perform(%{order_by: [visitors: :desc]}).order_by == [{:visitors, :desc}]
    end

    test "adds first metric to order_by if order_by not specified" do
      assert perform(%{metrics: [:pageviews, :visitors]}).order_by == [{:pageviews, :desc}]

      assert perform(%{metrics: [:pageviews, :visitors], dimensions: ["event:page"]}).order_by ==
               [{:pageviews, :desc}]
    end

    test "adds time and first metric to order_by if order_by not specified" do
      assert perform(%{
               date_range: Date.range(~N[2022-01-01 00:00:00], ~N[2022-02-01 00:00:00]),
               metrics: [:pageviews, :visitors],
               dimensions: ["time", "event:page"]
             }).order_by ==
               [{"time:day", :asc}, {:pageviews, :desc}]
    end
  end

  describe "update_group_by_time" do
    test "does nothing if `time` dimension not passed" do
      assert perform(%{
               date_range: Date.range(~N[2022-01-01 00:00:00], ~N[2022-01-05 00:00:00]),
               dimensions: ["time:month"]
             }).dimensions == ["time:month"]
    end

    test "updating time dimension" do
      assert perform(%{
               date_range: Date.range(~N[2022-01-01 00:00:00], ~N[2022-01-01 05:00:00]),
               dimensions: ["time"]
             }).dimensions == ["time:hour"]

      assert perform(%{
               date_range: Date.range(~N[2022-01-01 00:00:00], ~N[2022-01-02 00:00:00]),
               dimensions: ["time"]
             }).dimensions == ["time:hour"]

      assert perform(%{
               date_range: Date.range(~N[2022-01-01 00:00:00], ~N[2022-01-02 16:00:00]),
               dimensions: ["time"]
             }).dimensions == ["time:hour"]

      assert perform(%{
               date_range: Date.range(~D[2022-01-01], ~D[2022-01-04]),
               dimensions: ["time"]
             }).dimensions == ["time:day"]

      assert perform(%{
               date_range: Date.range(~D[2022-01-01], ~D[2022-01-10]),
               dimensions: ["time"]
             }).dimensions == ["time:day"]

      assert perform(%{
               date_range: Date.range(~D[2022-01-01], ~D[2022-01-16]),
               dimensions: ["time"]
             }).dimensions == ["time:day"]

      assert perform(%{
               date_range: Date.range(~D[2022-01-01], ~D[2022-02-16]),
               dimensions: ["time"]
             }).dimensions == ["time:month"]

      assert perform(%{
               date_range: Date.range(~D[2022-01-01], ~D[2022-03-16]),
               dimensions: ["time"]
             }).dimensions == ["time:month"]

      assert perform(%{
               date_range: Date.range(~D[2022-01-01], ~D[2022-03-16]),
               dimensions: ["time"]
             }).dimensions == ["time:month"]

      assert perform(%{
               date_range: Date.range(~D[2022-01-01], ~D[2023-11-16]),
               dimensions: ["time"]
             }).dimensions == ["time:month"]

      assert perform(%{
               date_range: Date.range(~D[2022-01-01], ~D[2024-01-16]),
               dimensions: ["time"]
             }).dimensions == ["time:month"]

      assert perform(%{
               date_range: Date.range(~D[2022-01-01], ~D[2026-01-01]),
               dimensions: ["time"]
             }).dimensions == ["time:month"]
    end
  end

  describe "update_time_in_order_by" do
    test "updates explicit time dimension in order_by" do
      assert perform(%{
               date_range: Date.range(~N[2022-01-01 00:00:00], ~N[2022-01-01 05:00:00]),
               dimensions: ["time:hour"],
               order_by: [{"time", :asc}]
             }).order_by == [{"time:hour", :asc}]
    end
  end

  describe "extend_hostname_filters_to_visit" do
    test "updates filters it filtering by event:hostname and visit:referrer and visit:exit_page dimensions" do
      assert perform(%{
               date_range: Date.range(~N[2022-01-01 00:00:00], ~N[2022-01-01 05:00:00]),
               filters: [
                 [:is, "event:hostname", ["example.com"]],
                 [:matches, "event:hostname", ["*.com"]]
               ],
               dimensions: ["visit:referrer", "visit:exit_page"]
             }).filters == [
               [:is, "event:hostname", ["example.com"]],
               [:matches, "event:hostname", ["*.com"]],
               [:is, "visit:entry_page_hostname", ["example.com"]],
               [:matches, "visit:entry_page_hostname", ["*.com"]],
               [:is, "visit:exit_page_hostname", ["example.com"]],
               [:matches, "visit:exit_page_hostname", ["*.com"]]
             ]
    end

    test "does not update filters if not needed" do
      assert perform(%{
               date_range: Date.range(~N[2022-01-01 00:00:00], ~N[2022-01-01 05:00:00]),
               filters: [
                 [:is, "event:hostname", ["example.com"]]
               ],
               dimensions: ["time", "event:hostname"]
             }).filters == [
               [:is, "event:hostname", ["example.com"]]
             ]
    end
  end
end
