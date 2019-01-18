defmodule PlausibleWeb.PageController do
  use PlausibleWeb, :controller
  use Plausible.Repo
  @half_hour_in_seconds 30 * 60

  def index(conn, _params) do
    if get_session(conn, :current_user_email) do
      user = Plausible.Repo.get_by!(Plausible.Auth.User, email: get_session(conn, :current_user_email))
             |> Plausible.Repo.preload(:sites)
      render(conn, "sites.html", sites: user.sites)
    else
      render(conn, "index.html", landing_nav: true)
    end
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def onboarding(conn, _params) do
    if get_session(conn, :current_user_email) do
      redirect(conn, to: "/")
    else
      render(conn, "onboarding_enter_email.html")
    end
  end

  def new_site(conn, _params) do
    render(conn, "new_site.html")
  end

  defp insert_site(user_id, domain) do
    site_changeset = Plausible.Site.changeset(%Plausible.Site{}, %{domain: domain})

    {:ok, %{site: site}} = Ecto.Multi.new()
    |> Ecto.Multi.insert(:site, site_changeset)
    |>  Ecto.Multi.run(:site_membership, fn repo, %{site: site} ->
      membership_changeset = Plausible.Site.Membership.changeset(%Plausible.Site.Membership{}, %{
        site_id: site.id,
        user_id: user_id
      })
      repo.insert(membership_changeset)
    end)
    |> Repo.transaction
    site
  end

  def add_snippet(conn, %{"website" => website}) do
    site = Plausible.Repo.get_by!(Plausible.Site, domain: website)
    render(conn, "site_snippet.html", site: site)
  end

  def create_site(conn, %{"domain" => domain}) do
    user = Plausible.Repo.get_by!(Plausible.Auth.User, email: get_session(conn, :current_user_email))

    site = insert_site(user.id, domain)

    redirect(conn, to: "/#{site.domain}/snippet")
  end

  def send_login_link(conn, %{"email" => email}) do
    token = Phoenix.Token.sign(PlausibleWeb.Endpoint, "email_login", %{email: email})
    url = PlausibleWeb.Endpoint.url() <> "/claim-login?token=#{token}"
    require Logger
    Logger.debug(url)
    email_template = PlausibleWeb.Email.login_email(email, url)
    Plausible.Mailer.deliver_now(email_template)
    conn |> render("login_success.html", email: email)
  end

  def login_form(conn, _params) do
    render(conn, "login_form.html")
  end

  defp successful_login(email) do
    found_user = Repo.get_by(Plausible.Auth.User, email: email)
    if found_user do
      :found
    else
      Plausible.Auth.User.changeset(%Plausible.Auth.User{}, %{email: email})
        |> Plausible.Repo.insert!
      :new
    end
  end

  def claim_login_link(conn, %{"token" => token}) do
    case Phoenix.Token.verify(PlausibleWeb.Endpoint, "email_login", token, max_age: @half_hour_in_seconds) do
      {:ok, %{email: email}} ->
        conn = put_session(conn, :current_user_email, email)

        case successful_login(email) do
          :new ->
            redirect(conn, to: "/sites/new")
          :found ->
            redirect(conn, to: "/")
        end
      {:error, :expired} ->
        conn |> send_resp(401, "Your login token has expired")
      {:error, _} ->
        conn |> send_resp(400, "Your login token is invalid")
    end
  end

  defp show_analytics(conn, website, total_pageviews) do
    {period, date_range} = get_date_range(conn.params)

    base_query = from(p in Plausible.Pageview,
      where: p.hostname == ^website,
      where: type(p.inserted_at, :date) >= ^date_range.first and type(p.inserted_at, :date) <= ^date_range.last
    )

    pageview_groups = Repo.all(
      from p in base_query,
      group_by: 1,
      order_by: 1,
      select: {type(p.inserted_at, :date), count(p.id)}
    ) |> Enum.into(%{})

    plot = Enum.map(date_range, fn day ->
      pageview_groups[day] || 0
    end)

    labels = Enum.map(date_range, fn date ->
      Timex.format!(date, "{WDshort} {D} {Mshort}")
    end)

    unique_visitors = Repo.aggregate(from(
      p in base_query,
      where: p.new_visitor
    ), :count, :id)

    device_types = Repo.all(from p in base_query,
      select: {p.device_type, count(p.device_type)},
      group_by: p.device_type,
      where: p.new_visitor == true,
      order_by: [desc: count(p.device_type)],
      limit: 5
    )

    browsers = Repo.all(from p in base_query,
      select: {p.browser, count(p.browser)},
      group_by: p.browser,
      where: p.new_visitor == true,
      order_by: [desc: count(p.browser)],
      limit: 5
    )

    operating_systems = Repo.all(from p in base_query,
      select: {p.operating_system, count(p.operating_system)},
      group_by: p.operating_system,
      where: p.new_visitor == true,
      order_by: [desc: count(p.operating_system)],
      limit: 5
    )

    top_referrers = Repo.all(from p in base_query,
      select: {p.referrer_source, count(p.referrer_source)},
      group_by: p.referrer_source,
      where: p.new_visitor == true and not is_nil(p.referrer_source),
      order_by: [desc: count(p.referrer_source)],
      limit: 5
    )

    top_pages = Repo.all(from p in base_query,
      select: {p.pathname, count(p.pathname)},
      group_by: p.pathname,
      order_by: [desc: count(p.pathname)],
      limit: 5
    )

    top_screen_sizes = Repo.all(from p in base_query,
      select: {p.screen_size, count(p.screen_size)},
      group_by: p.screen_size,
      order_by: [desc: count(p.screen_size)],
      limit: 5
    )

    render(conn, "analytics.html",
      plot: plot,
      labels: labels,
      pageviews: total_pageviews,
      unique_visitors: unique_visitors,
      top_referrers: top_referrers,
      top_pages: top_pages,
      top_screen_sizes: top_screen_sizes,
      device_types: device_types,
      browsers: browsers,
      operating_systems: operating_systems,
      hostname: website,
      title: "Plausible · " <> website,
      selected_period: period
    )
  end


  def analytics(conn, %{"website" => website} = params) do
    site = Repo.get_by(Plausible.Site, domain: website)

    if site do
      {period, date_range} = get_date_range(params)

      pageviews = Repo.aggregate(
        from(p in Plausible.Pageview,
        where: p.hostname == ^website,
        where: type(p.inserted_at, :date) >= ^date_range.first and type(p.inserted_at, :date) <= ^date_range.last
      ), :count, :id)

      if pageviews == 0 do
        render(conn, "waiting_first_pageview.html")
      else
        show_analytics(conn, website, pageviews)
      end
    else
      conn |> send_resp(404, "Website not found")
    end
  end

  defp get_date_range(%{"period" => "today"}) do
    date_range = Date.range(Timex.today(), Timex.today())
    {"today", date_range}
  end

  defp get_date_range(%{"period" => "7days"}) do
    start_date = Timex.shift(Timex.today(), days: -7)
    date_range = Date.range(start_date, Timex.today())
    {"7days", date_range}
  end

  defp get_date_range(%{"period" => "30days"}) do
    start_date = Timex.shift(Timex.today(), days: -30)
    date_range = Date.range(start_date, Timex.today())
    {"30days", date_range}
  end

  defp get_date_range(_) do
    get_date_range(%{"period" => "30days"})
  end

  defp browser_name(ua) do
    case ua.client do
      %UAInspector.Result.Client{name: "Mobile Safari"} -> "Safari"
      %UAInspector.Result.Client{name: "Chrome Mobile"} -> "Chrome"
      %UAInspector.Result.Client{name: "Chrome Mobile iOS"} -> "Chrome"
      %UAInspector.Result.Client{type: "mobile app"} -> "Mobile App"
      client -> client.name
    end
  end

  defp device_type(ua) do
    case ua.device do
      :unknown -> "unknown"
      device -> device.type
    end
  end

  defp operating_system(ua) do
    ua.os.name
  end
end
