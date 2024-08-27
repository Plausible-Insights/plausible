defmodule Plausible.Stats.Filters.QueryParserTest do
  use Plausible.DataCase

  alias Plausible.Stats.Filters
  import Plausible.Stats.Filters.QueryParser

  setup [:create_user, :create_new_site]

  @today ~D[2021-05-05]
  @date_range Date.range(@today, @today)

  def check_success(params, site, expected_result),
    do: check_success(params, site, :public, expected_result)

  def check_success(params, site, schema_type, expected_result) do
    assert {:ok, ^expected_result} = parse(site, schema_type, params, @today)
  end

  def check_error(params, site, expected_error_message),
    do: check_error(params, site, :public, expected_error_message)

  def check_error(params, site, schema_type, expected_error_message) do
    {:error, message} = parse(site, schema_type, params, @today)
    assert message == expected_error_message
  end

  def check_date_range(date_range, site, expected_date_range) do
    %{"site_id" => site.domain, "metrics" => ["visitors", "events"], "date_range" => date_range}
    |> check_success(site, %{
      metrics: [:visitors, :events],
      date_range: expected_date_range,
      filters: [],
      dimensions: [],
      order_by: nil,
      timezone: site.timezone,
      include: %{imports: false, time_labels: false},
      preloaded_goals: []
    })
  end

  test "parsing empty map fails", %{site: site} do
    %{}
    |> check_error(site, "#: Required properties site_id, metrics, date_range were not present.")
  end

  describe "metrics validation" do
    test "valid metrics passed", %{site: site} do
      %{"site_id" => site.domain, "metrics" => ["visitors", "events"], "date_range" => "all"}
      |> check_success(site, %{
        metrics: [:visitors, :events],
        date_range: @date_range,
        filters: [],
        dimensions: [],
        order_by: nil,
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })
    end

    test "invalid metric passed", %{site: site} do
      %{"site_id" => site.domain, "metrics" => ["visitors", "event:name"], "date_range" => "all"}
      |> check_error(site, "#/metrics/1: Invalid metric \"event:name\"")
    end

    test "fuller list of metrics", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => [
          "time_on_page",
          "visitors",
          "pageviews",
          "visits",
          "events",
          "bounce_rate",
          "visit_duration"
        ],
        "date_range" => "all"
      }
      |> check_success(site, :internal, %{
        metrics: [
          :time_on_page,
          :visitors,
          :pageviews,
          :visits,
          :events,
          :bounce_rate,
          :visit_duration
        ],
        date_range: @date_range,
        filters: [],
        dimensions: [],
        order_by: nil,
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })
    end

    test "time_on_page is not a valid metric in public API", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["time_on_page"],
        "date_range" => "all"
      }
      |> check_error(site, :public, "#/metrics/0: Invalid metric \"time_on_page\"")
    end

    test "same metric queried multiple times", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["events", "visitors", "visitors"],
        "date_range" => "all"
      }
      |> check_error(site, "#/metrics: Expected items to be unique but they were not.")
    end

    test "no metrics passed", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => [],
        "date_range" => "all"
      }
      |> check_error(site, "#/metrics: Expected a minimum of 1 items but got 0.")
    end
  end

  describe "filters validation" do
    for operation <- [:is, :is_not, :matches, :does_not_match, :contains, :does_not_contain] do
      test "#{operation} filter", %{site: site} do
        %{
          "site_id" => site.domain,
          "metrics" => ["visitors"],
          "date_range" => "all",
          "filters" => [
            [Atom.to_string(unquote(operation)), "event:name", ["foo"]]
          ]
        }
        |> check_success(site, :internal, %{
          metrics: [:visitors],
          date_range: @date_range,
          filters: [
            [unquote(operation), "event:name", ["foo"]]
          ],
          dimensions: [],
          order_by: nil,
          timezone: site.timezone,
          include: %{imports: false, time_labels: false},
          preloaded_goals: []
        })
      end

      test "#{operation} filter with invalid clause", %{site: site} do
        %{
          "site_id" => site.domain,
          "metrics" => ["visitors"],
          "date_range" => "all",
          "filters" => [
            [Atom.to_string(unquote(operation)), "event:name", "foo"]
          ]
        }
        |> check_error(
          site,
          :internal,
          "#/filters/0: Invalid filter [\"#{unquote(operation)}\", \"event:name\", \"foo\"]"
        )
      end
    end

    for operation <- [:matches, :does_not_match] do
      test "#{operation} is not a valid filter operation in public API", %{site: site} do
        %{
          "site_id" => site.domain,
          "metrics" => ["visitors"],
          "date_range" => "all",
          "filters" => [
            [Atom.to_string(unquote(operation)), "event:name", ["foo"]]
          ]
        }
        |> check_error(
          site,
          :public,
          "#/filters/0: Invalid filter [\"#{unquote(operation)}\", \"event:name\", [\"foo\"]]"
        )
      end
    end

    test "filtering by invalid operation", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [
          ["exists?", "event:name", ["foo"]]
        ]
      }
      |> check_error(site, "#/filters/0: Invalid filter [\"exists?\", \"event:name\", [\"foo\"]]")
    end

    test "filtering by custom properties", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [
          ["is", "event:props:foobar", ["value"]]
        ]
      }
      |> check_success(site, %{
        metrics: [:visitors],
        date_range: @date_range,
        filters: [
          [:is, "event:props:foobar", ["value"]]
        ],
        dimensions: [],
        order_by: nil,
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })
    end

    for dimension <- Filters.event_props() do
      if dimension != "goal" do
        test "filtering by event:#{dimension} filter", %{site: site} do
          %{
            "site_id" => site.domain,
            "metrics" => ["visitors"],
            "date_range" => "all",
            "filters" => [
              ["is", "event:#{unquote(dimension)}", ["foo"]]
            ]
          }
          |> check_success(site, %{
            metrics: [:visitors],
            date_range: @date_range,
            filters: [
              [:is, "event:#{unquote(dimension)}", ["foo"]]
            ],
            dimensions: [],
            order_by: nil,
            timezone: site.timezone,
            include: %{imports: false, time_labels: false},
            preloaded_goals: []
          })
        end
      end
    end

    for dimension <- Filters.visit_props() do
      test "filtering by visit:#{dimension} filter", %{site: site} do
        %{
          "site_id" => site.domain,
          "metrics" => ["visitors"],
          "date_range" => "all",
          "filters" => [
            ["is", "visit:#{unquote(dimension)}", ["ab"]]
          ]
        }
        |> check_success(site, %{
          metrics: [:visitors],
          date_range: @date_range,
          filters: [
            [:is, "visit:#{unquote(dimension)}", ["ab"]]
          ],
          dimensions: [],
          order_by: nil,
          timezone: site.timezone,
          include: %{imports: false, time_labels: false},
          preloaded_goals: []
        })
      end
    end

    test "invalid event filter", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [
          ["is", "event:device", ["foo"]]
        ]
      }
      |> check_error(site, "#/filters/0: Invalid filter [\"is\", \"event:device\", [\"foo\"]]")
    end

    test "invalid visit filter", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [
          ["is", "visit:name", ["foo"]]
        ]
      }
      |> check_error(site, "#/filters/0: Invalid filter [\"is\", \"visit:name\", [\"foo\"]]")
    end

    test "invalid filter", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => "foobar"
      }
      |> check_error(site, "#/filters: Type mismatch. Expected Array but got String.")
    end

    test "numeric filter is invalid", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [["is", "visit:os_version", [123]]]
      }
      |> check_error(site, "Invalid filter '[\"is\", \"visit:os_version\", [123]]'.")
    end

    test "numbers and strings are valid for visit:city", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [["is", "visit:city", [123, 456]]]
      }
      |> check_success(site, %{
        metrics: [:visitors],
        date_range: @date_range,
        filters: [
          [:is, "visit:city", [123, 456]]
        ],
        dimensions: [],
        order_by: nil,
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })

      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [["is", "visit:city", ["123", "456"]]]
      }
      |> check_success(site, %{
        metrics: [:visitors],
        date_range: @date_range,
        filters: [
          [:is, "visit:city", ["123", "456"]]
        ],
        dimensions: [],
        order_by: nil,
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })
    end

    test "invalid visit:country filter", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [["is", "visit:country", ["USA"]]]
      }
      |> check_error(
        site,
        "Invalid visit:country filter, visit:country needs to be a valid 2-letter country code."
      )
    end
  end

  describe "include validation" do
    test "setting include values", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "dimensions" => ["time"],
        "include" => %{"imports" => true, "time_labels" => true}
      }
      |> check_success(site, %{
        metrics: [:visitors],
        date_range: @date_range,
        filters: [],
        dimensions: ["time"],
        order_by: nil,
        timezone: site.timezone,
        include: %{imports: true, time_labels: true},
        preloaded_goals: []
      })
    end

    test "setting invalid imports value", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "include" => "foobar"
      }
      |> check_error(site, "#/include: Type mismatch. Expected Object but got String.")
    end

    test "setting include.time_labels without time dimension", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "include" => %{"time_labels" => true}
      }
      |> check_error(site, "Invalid include.time_labels: requires a time dimension.")
    end
  end

  describe "event:goal filter validation" do
    test "valid filters", %{site: site} do
      insert(:goal, %{site: site, event_name: "Signup"})
      insert(:goal, %{site: site, page_path: "/thank-you"})

      params = %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [
          ["is", "event:goal", ["Signup", "Visit /thank-you"]]
        ]
      }

      assert {:ok, res} = parse(site, :public, params, @today)
      expected_timezone = site.timezone

      assert %{
               metrics: [:visitors],
               date_range: @date_range,
               filters: [
                 [:is, "event:goal", ["Signup", "Visit /thank-you"]]
               ],
               dimensions: [],
               order_by: nil,
               timezone: ^expected_timezone,
               include: %{imports: false, time_labels: false},
               preloaded_goals: [
                 %Plausible.Goal{page_path: "/thank-you"},
                 %Plausible.Goal{event_name: "Signup"}
               ]
             } = res
    end

    test "invalid event filter", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [
          ["is", "event:goal", ["Signup"]]
        ]
      }
      |> check_error(
        site,
        "The goal `Signup` is not configured for this site. Find out how to configure goals here: https://plausible.io/docs/stats-api#filtering-by-goals"
      )
    end

    test "invalid page filter", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [
          ["is", "event:goal", ["Visit /thank-you"]]
        ]
      }
      |> check_error(
        site,
        "The goal `Visit /thank-you` is not configured for this site. Find out how to configure goals here: https://plausible.io/docs/stats-api#filtering-by-goals"
      )
    end
  end

  describe "date range validation" do
    test "parsing shortcut options", %{site: site} do
      check_date_range("day", site, Date.range(~D[2021-05-05], ~D[2021-05-05]))
      check_date_range("7d", site, Date.range(~D[2021-04-29], ~D[2021-05-05]))
      check_date_range("30d", site, Date.range(~D[2021-04-05], ~D[2021-05-05]))
      check_date_range("month", site, Date.range(~D[2021-05-01], ~D[2021-05-31]))
      check_date_range("6mo", site, Date.range(~D[2020-12-01], ~D[2021-05-31]))
      check_date_range("12mo", site, Date.range(~D[2020-06-01], ~D[2021-05-31]))
      check_date_range("year", site, Date.range(~D[2021-01-01], ~D[2021-12-31]))
    end

    test "parsing `all` with previous data", %{site: site} do
      site = Map.put(site, :stats_start_date, ~D[2020-01-01])
      check_date_range("all", site, Date.range(~D[2020-01-01], ~D[2021-05-05]))
    end

    test "parsing `all` with no previous data", %{site: site} do
      site = Map.put(site, :stats_start_date, nil)

      check_date_range("all", site, Date.range(~D[2021-05-05], ~D[2021-05-05]))
    end

    test "parsing custom date range", %{site: site} do
      check_date_range(
        ["2021-05-05", "2021-05-05"],
        site,
        Date.range(~D[2021-05-05], ~D[2021-05-05])
      )
    end

    test "parsing invalid custom date range", %{site: site} do
      %{"site_id" => site.domain, "date_range" => "foo", "metrics" => ["visitors"]}
      |> check_error(site, "#/date_range: Invalid date range \"foo\"")

      %{"site_id" => site.domain, "date_range" => ["21415-00", "eee"], "metrics" => ["visitors"]}
      |> check_error(site, "#/date_range: Invalid date range [\"21415-00\", \"eee\"]")
    end
  end

  describe "dimensions validation" do
    for dimension <- Filters.event_props() do
      test "event:#{dimension} dimension", %{site: site} do
        %{
          "site_id" => site.domain,
          "metrics" => ["visitors"],
          "date_range" => "all",
          "dimensions" => ["event:#{unquote(dimension)}"]
        }
        |> check_success(site, %{
          metrics: [:visitors],
          date_range: @date_range,
          filters: [],
          dimensions: ["event:#{unquote(dimension)}"],
          order_by: nil,
          timezone: site.timezone,
          include: %{imports: false, time_labels: false},
          preloaded_goals: []
        })
      end
    end

    for dimension <- Filters.visit_props() do
      test "visit:#{dimension} dimension", %{site: site} do
        %{
          "site_id" => site.domain,
          "metrics" => ["visitors"],
          "date_range" => "all",
          "dimensions" => ["visit:#{unquote(dimension)}"]
        }
        |> check_success(site, %{
          metrics: [:visitors],
          date_range: @date_range,
          filters: [],
          dimensions: ["visit:#{unquote(dimension)}"],
          order_by: nil,
          timezone: site.timezone,
          include: %{imports: false, time_labels: false},
          preloaded_goals: []
        })
      end
    end

    test "custom properties dimension", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "dimensions" => ["event:props:foobar"]
      }
      |> check_success(site, %{
        metrics: [:visitors],
        date_range: @date_range,
        filters: [],
        dimensions: ["event:props:foobar"],
        order_by: nil,
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })
    end

    test "invalid custom property dimension", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "dimensions" => ["event:props:"]
      }
      |> check_error(site, "#/dimensions/0: Invalid dimension \"event:props:\"")
    end

    test "invalid dimension name passed", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "dimensions" => ["visitors"]
      }
      |> check_error(site, "#/dimensions/0: Invalid dimension \"visitors\"")
    end

    test "invalid dimension", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "dimensions" => "foobar"
      }
      |> check_error(site, "#/dimensions: Type mismatch. Expected Array but got String.")
    end

    test "dimensions are not unique", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "dimensions" => ["event:name", "event:name"]
      }
      |> check_error(site, "#/dimensions: Expected items to be unique but they were not.")
    end
  end

  describe "order_by validation" do
    test "ordering by metric", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors", "events"],
        "date_range" => "all",
        "order_by" => [["events", "desc"], ["visitors", "asc"]]
      }
      |> check_success(site, %{
        metrics: [:visitors, :events],
        date_range: @date_range,
        filters: [],
        dimensions: [],
        order_by: [{:events, :desc}, {:visitors, :asc}],
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })
    end

    test "ordering by dimension", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "dimensions" => ["event:name"],
        "order_by" => [["event:name", "desc"]]
      }
      |> check_success(site, %{
        metrics: [:visitors],
        date_range: @date_range,
        filters: [],
        dimensions: ["event:name"],
        order_by: [{"event:name", :desc}],
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })
    end

    test "ordering by invalid value", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "order_by" => [["visssss", "desc"]]
      }
      |> check_error(site, "#/order_by/0/0: Invalid value in order_by \"visssss\"")
    end

    test "ordering by not queried metric", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "order_by" => [["events", "desc"]]
      }
      |> check_error(
        site,
        "Invalid order_by entry '{:events, :desc}'. Entry is not a queried metric or dimension."
      )
    end

    test "ordering by not queried dimension", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "order_by" => [["event:name", "desc"]]
      }
      |> check_error(
        site,
        "Invalid order_by entry '{\"event:name\", :desc}'. Entry is not a queried metric or dimension."
      )
    end
  end

  describe "custom props access" do
    test "error if invalid filter", %{site: site, user: user} do
      ep =
        insert(:enterprise_plan, features: [Plausible.Billing.Feature.StatsAPI], user_id: user.id)

      insert(:subscription, user: user, paddle_plan_id: ep.paddle_plan_id)

      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "filters" => [["is", "event:props:foobar", ["foo"]]]
      }
      |> check_error(
        site,
        "The owner of this site does not have access to the custom properties feature."
      )
    end

    test "error if invalid dimension", %{site: site, user: user} do
      ep =
        insert(:enterprise_plan, features: [Plausible.Billing.Feature.StatsAPI], user_id: user.id)

      insert(:subscription, user: user, paddle_plan_id: ep.paddle_plan_id)

      %{
        "site_id" => site.domain,
        "metrics" => ["visitors"],
        "date_range" => "all",
        "dimensions" => ["event:props:foobar"]
      }
      |> check_error(
        site,
        "The owner of this site does not have access to the custom properties feature."
      )
    end
  end

  describe "conversion_rate metric" do
    test "fails validation on its own", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["conversion_rate"],
        "date_range" => "all"
      }
      |> check_error(
        site,
        "Metric `conversion_rate` can only be queried with event:goal filters or dimensions."
      )
    end

    # test "succeeds with event:goal filter", %{site: site} do
    #   insert(:goal, %{site: site, event_name: "Signup"})

    #   %{
    #     "metrics" => ["conversion_rate"],
    #     "date_range" => "all",
    #     "filters" => [["is", "event:goal", ["Signup"]]]
    #   }
    #   |> check_success(site, %{
    #     metrics: [:conversion_rate],
    #     date_range: @date_range,
    #     filters: [[:is, "event:goal", [event: "Signup"]]],
    #     dimensions: [],
    #     order_by: nil,
    #     timezone: site.timezone,
    #     include: %{imports: false, time_labels: false},
    #     preloaded_goals: [event: "Signup"]
    #   })
    # end

    # test "succeeds with event:goal dimension", %{site: site} do
    #   goal = insert(:goal, %{site: site, event_name: "Signup"})

    #   %{
    #     "metrics" => ["conversion_rate"],
    #     "date_range" => "all",
    #     "dimensions" => ["event:goal"]
    #   }
    #   |> check_success(site, %{
    #     metrics: [:conversion_rate],
    #     date_range: @date_range,
    #     filters: [],
    #     dimensions: ["event:goal"],
    #     order_by: nil,
    #     timezone: site.timezone,
    #     include: %{imports: false, time_labels: false},
    #     preloaded_goals: [goal]
    #   })
    # end
  end

  describe "views_per_visit metric" do
    # test "succeeds with normal filters", %{site: site} do
    #   insert(:goal, %{site: site, event_name: "Signup"})

    #   %{
    #     "metrics" => ["views_per_visit"],
    #     "date_range" => "all",
    #     "filters" => [["is", "event:goal", ["Signup"]]]
    #   }
    #   |> check_success(site, %{
    #     metrics: [:views_per_visit],
    #     date_range: @date_range,
    #     filters: [[:is, "event:goal", [event: "Signup"]]],
    #     dimensions: [],
    #     order_by: nil,
    #     timezone: site.timezone,
    #     include: %{imports: false, time_labels: false},
    #     preloaded_goals: [event: "Signup"]
    #   })
    # end

    test "fails validation if event:page filter specified", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["views_per_visit"],
        "date_range" => "all",
        "filters" => [["is", "event:page", ["/"]]]
      }
      |> check_error(
        site,
        "Metric `views_per_visit` cannot be queried with a filter on `event:page`."
      )
    end

    test "fails validation with dimensions", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["views_per_visit"],
        "date_range" => "all",
        "dimensions" => ["event:name"]
      }
      |> check_error(
        site,
        "Metric `views_per_visit` cannot be queried with `dimensions`."
      )
    end
  end

  describe "session metrics" do
    test "single session metric succeeds", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["bounce_rate"],
        "date_range" => "all",
        "dimensions" => ["visit:device"]
      }
      |> check_success(site, %{
        metrics: [:bounce_rate],
        date_range: @date_range,
        filters: [],
        dimensions: ["visit:device"],
        order_by: nil,
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })
    end

    test "fails if using session metric with event dimension", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["bounce_rate"],
        "date_range" => "all",
        "dimensions" => ["event:props:foo"]
      }
      |> check_error(
        site,
        "Session metric(s) `bounce_rate` cannot be queried along with event dimensions."
      )
    end

    test "does not fail if using session metric with event:page dimension", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["bounce_rate"],
        "date_range" => "all",
        "dimensions" => ["event:page"]
      }
      |> check_success(site, %{
        metrics: [:bounce_rate],
        date_range: @date_range,
        filters: [],
        dimensions: ["event:page"],
        order_by: nil,
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })
    end

    test "does not fail if using session metric with event filter", %{site: site} do
      %{
        "site_id" => site.domain,
        "metrics" => ["bounce_rate"],
        "date_range" => "all",
        "filters" => [["is", "event:props:foo", ["(none)"]]]
      }
      |> check_success(site, %{
        metrics: [:bounce_rate],
        date_range: @date_range,
        filters: [[:is, "event:props:foo", ["(none)"]]],
        dimensions: [],
        order_by: nil,
        timezone: site.timezone,
        include: %{imports: false, time_labels: false},
        preloaded_goals: []
      })
    end
  end
end
