defmodule Plausible.Analytics.Query do
  defstruct [date_range: nil, step_type: nil]

  def new(attrs) do
    attrs
      |> Enum.into(%{})
      |> Map.put(:__struct__, __MODULE__)
  end
end

defmodule Plausible.Analytics do
  use Plausible.Repo
  alias Plausible.Analytics.Query

  defp transform_keys(map, fun) do
    for {key, val} <- map, into: %{} do
      {fun.(key), val}
    end
  end

  def calculate_plot(site, query) do
    groups = pageview_groups(site, query)

    steps = case query.step_type do
      "hour" ->
        current_hour = Timex.now(site.timezone).hour
        Enum.map(0..current_hour, fn shift ->
          Timex.now(site.timezone)
          |> Timex.beginning_of_day()
          |> Timex.shift(hours: shift)
          |> DateTime.to_naive
        end)
      "date" ->
        query.date_range
    end

    Enum.map(steps, fn step -> groups[step] || 0 end)
  end

  def labels(site, %Query{step_type: "date"} = query) do
    Enum.map(query.date_range, fn date ->
      Timex.format!(date, "{D} {Mshort}")
    end)
  end

  def labels(site, %Query{step_type: "hour"} = query) do
    Enum.map(0..23, fn shift ->
      Timex.now(site.timezone)
      |> Timex.beginning_of_day()
      |> Timex.shift(hours: shift)
      |> DateTime.to_naive
      |> Timex.format!("{h12}{am}")
    end)
  end

  defp pageview_groups(site, %Query{step_type: "date"} = query) do
    Repo.all(
      from p in base_query(site, query),
      group_by: 1,
      order_by: 1,
      select: {fragment("(? at time zone 'utc' at time zone ?)::date", p.inserted_at, ^site.timezone), count(p.id)}
    ) |> Enum.into(%{})
  end

  defp pageview_groups(site, %Query{step_type: "hour"} = query) do
    Repo.all(
      from p in base_query(site, query),
      group_by: 1,
      order_by: 1,
      select: {fragment("date_trunc(?, ? at time zone 'utc' at time zone ?)", "hour", p.inserted_at, ^site.timezone), count(p.id)}
    )
    |> Enum.into(%{})
    |> transform_keys(fn dt -> NaiveDateTime.truncate(dt, :second) end)
  end

  def total_pageviews(site, query) do
    Repo.aggregate(base_query(site, query), :count, :id)
  end

  def unique_visitors(site, query) do
    Repo.one(from(
      p in base_query(site, query),
      select: count(p.user_id, :distinct)
    ))
  end

  def top_referrers(site, query) do
    Repo.all(from p in base_query(site, query),
      select: {p.referrer_source, count(p.referrer_source)},
      group_by: p.referrer_source,
      where: p.new_visitor == true and not is_nil(p.referrer_source),
      order_by: [desc: 2],
      limit: 5
    )
  end

  def top_pages(site, query) do
    Repo.all(from p in base_query(site, query),
      select: {p.pathname, count(p.pathname)},
      group_by: p.pathname,
      order_by: [desc: count(p.pathname)],
      limit: 5
    )
  end

  def top_screen_sizes(site, query) do
    Repo.all(from p in base_query(site, query),
      select: {p.screen_size, count(p.screen_size)},
      group_by: p.screen_size,
      order_by: [desc: count(p.screen_size)],
      limit: 5
    )
  end

  def device_types(site, query) do
    Repo.all(from p in base_query(site, query),
      select: {p.device_type, count(p.device_type)},
      group_by: p.device_type,
      where: p.new_visitor == true,
      order_by: [desc: count(p.device_type)],
      limit: 5
    )
  end

  def browsers(site, query) do
    Repo.all(from p in base_query(site, query),
      select: {p.browser, count(p.browser)},
      group_by: p.browser,
      where: p.new_visitor == true,
      order_by: [desc: count(p.browser)],
      limit: 5
    )
  end

  def operating_systems(site, query) do
    Repo.all(from p in base_query(site, query),
      select: {p.operating_system, count(p.operating_system)},
      group_by: p.operating_system,
      where: p.new_visitor == true,
      order_by: [desc: count(p.operating_system)],
      limit: 5
    )
  end

  defp base_query(site, query) do
    from(p in Plausible.Pageview,
      where: p.hostname == ^site.domain,
      where: type(fragment("(? at time zone 'utc' at time zone ?)", p.inserted_at, ^site.timezone), :date) >= ^query.date_range.first and type(fragment("(? at time zone 'utc' at time zone ?)", p.inserted_at, ^site.timezone), :date) <= ^query.date_range.last
    )
  end
end
