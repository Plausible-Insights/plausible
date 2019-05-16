defmodule PlausibleWeb.StatsController do
  use PlausibleWeb, :controller
  use Plausible.Repo
  alias Plausible.Stats

  defp show_stats(conn, site) do
    demo = site.domain == "plausible.io"

    # TODO: This should move to localStorage when stats page is AJAX'ified
    {conn, period_params} = case conn.params["period"] do
      "custom" ->
        {conn, conn.params}
      p when p in ["day", "week", "month", "3mo"] ->
        saved_periods = get_session(conn, :saved_periods) || %{}
        {put_session(conn, :saved_periods, Map.merge(saved_periods, %{site.domain => p})), conn.params}
      _ ->
        saved_period = (get_session(conn, :saved_periods) || %{})[site.domain]

        if saved_period do
          {conn, %{"period" => saved_period}}
        else
          {conn, conn.params}
        end
    end

    Plausible.Tracking.event(conn, "Site Analytics: Open", %{demo: demo})

    query = Stats.Query.from(site.timezone, period_params)

    plot = Stats.calculate_plot(site, query)
    labels = Stats.labels(site, query)

		conn
    |> assign(:skip_plausible_tracking, !demo)
    |> render("stats.html",
      plot: plot,
      labels: labels,
      pageviews: Stats.total_pageviews(site, query),
      unique_visitors: Stats.unique_visitors(site, query),
      top_referrers: Stats.top_referrers(site, query),
      top_pages: Stats.top_pages(site, query),
      top_screen_sizes: Stats.top_screen_sizes(site, query),
      countries: Stats.countries(site, query),
      browsers: Stats.browsers(site, query),
      operating_systems: Stats.operating_systems(site, query),
      site: site,
      period: period_params["period"] || "month",
      query: query,
      title: "Plausible · " <> site.domain
    )
  end

  def stats(conn, %{"website" => website}) do
    site = Repo.get_by(Plausible.Site, domain: website)

    if site && current_user_can_access?(conn, site) do
      has_pageviews = Repo.exists?(
        from p in Plausible.Pageview,
        where: p.hostname == ^website
      )

      if has_pageviews do
        show_stats(conn, site)
      else
        conn
        |> assign(:skip_plausible_tracking, true)
        |> render("waiting_first_pageview.html", site: site)
      end
    else
      render_error(conn, 404)
    end
  end

  def referrers(conn, %{"domain" => domain}) do
    site = Repo.get_by(Plausible.Site, domain: domain)

    if site && current_user_can_access?(conn, site) do
      query = Stats.Query.from(site.timezone, conn.params)
      referrers = Stats.top_referrers(site, query, 100)

      render(conn, "referrers.html", layout: false, site: site, top_referrers: referrers)
    else
      render_error(conn, 404)
    end
  end

  def pages(conn, %{"domain" => domain}) do
    site = Repo.get_by(Plausible.Site, domain: domain)

    if site && current_user_can_access?(conn, site) do
      query = Stats.Query.from(site.timezone, conn.params)
      pages = Stats.top_pages(site, query, 100)

      render(conn, "pages.html", layout: false, site: site, top_pages: pages)
    else
      render_error(conn, 404)
    end
  end

  def countries(conn, %{"domain" => domain}) do
    site = Repo.get_by(Plausible.Site, domain: domain)

    if site && current_user_can_access?(conn, site) do
      query = Stats.Query.from(site.timezone, conn.params)
      countries = Stats.countries(site, query, 100)

      render(conn, "countries.html", layout: false, site: site, countries: countries)
    else
      render_error(conn, 404)
    end
  end

  def operating_systems(conn, %{"domain" => domain}) do
    site = Repo.get_by(Plausible.Site, domain: domain)

    if site && current_user_can_access?(conn, site) do
      query = Stats.Query.from(site.timezone, conn.params)
      operating_systems = Stats.operating_systems(site, query, 100)

      render(conn, "operating_systems.html", layout: false, site: site, operating_systems: operating_systems)
    else
      render_error(conn, 404)
    end
  end

  def browsers(conn, %{"domain" => domain}) do
    site = Repo.get_by(Plausible.Site, domain: domain)

    if site && current_user_can_access?(conn, site) do
      query = Stats.Query.from(site.timezone, conn.params)
      browsers = Stats.browsers(site, query, 100)

      render(conn, "browsers.html", layout: false, site: site, browsers: browsers)
    else
      render_error(conn, 404)
    end
  end

  defp current_user_can_access?(_conn, %Plausible.Site{domain: "plausible.io"}) do
    true
  end

  defp current_user_can_access?(conn, site) do
    case conn.assigns[:current_user] do
      nil -> false
      user -> Plausible.Sites.can_access?(user.id, site)
    end
  end
end
