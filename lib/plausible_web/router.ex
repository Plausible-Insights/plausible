defmodule PlausibleWeb.Router do
  use PlausibleWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug
  @two_weeks_in_seconds 60 * 60 * 24 * 14

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_device_id
    plug PlausibleWeb.SessionTimeoutPlug, timeout_after_seconds: @two_weeks_in_seconds
    plug PlausibleWeb.AuthPlug
    plug PlausibleWeb.LastSeenPlug
  end

  pipeline :api do
    plug :accepts, ["application/json"]
    plug :fetch_session
    plug PlausibleWeb.AuthPlug
  end

  if Mix.env == :dev do
    forward "/sent-emails", Bamboo.SentEmailViewerPlug
  end

  scope "/api", PlausibleWeb do
    pipe_through :api

    post "/page", Api.ExternalController, :page
    get "/error", Api.ExternalController, :error

    post "/paddle/webhook", Api.PaddleController, :webhook

    get "/:domain/status", Api.InternalController, :domain_status
    get "/:domain/referrers", StatsController, :referrers
    get "/:domain/referrers/:referrer", StatsController, :referrer_drilldown
    get "/:domain/pages", StatsController, :pages
    get "/:domain/countries", StatsController, :countries
    get "/:domain/operating-systems", StatsController, :operating_systems
    get "/:domain/browsers", StatsController, :browsers
  end

  scope "/", PlausibleWeb do
    pipe_through :browser

    get "/register", AuthController, :register_form
    post "/register", AuthController, :register
    get "/claim-activation", AuthController, :claim_activation_link
    get "/login", AuthController, :login_form
    post "/login", AuthController, :login
    get "/claim-login", AuthController, :claim_login_link
    get "/password/request-reset", AuthController, :password_reset_request_form
    post "/password/request-reset", AuthController, :password_reset_request
    get "/password/reset", AuthController, :password_reset_form
    post "/password/reset", AuthController, :password_reset
    get "/password", AuthController, :password_form
    post "/password", AuthController, :set_password
    post "/logout", AuthController, :logout
    get "/settings", AuthController, :user_settings
    put "/settings", AuthController, :save_settings
    delete "/me", AuthController, :delete_me

    get "/", PageController, :index
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms
    get "/data-policy", PageController, :data_policy
    get "/feedback", PageController, :feedback
    get "/roadmap", PageController, :roadmap
    get "/contact", PageController, :contact_form
    post "/contact", PageController, :submit_contact_form

    get "/billing/change-plan", BillingController, :change_plan_form
    post "/billing/change-plan/:plan_name", BillingController, :change_plan

    get "/billing/upgrade", BillingController, :upgrade

    get "/sites/new", SiteController, :new
    post "/sites", SiteController, :create_site
    post "/sites/:website/make-public", SiteController, :make_public
    post "/sites/:website/make-private", SiteController, :make_private
    get "/:website/snippet", SiteController, :add_snippet
    get "/:website/settings", SiteController, :settings
    put "/:website/settings", SiteController, :update_settings
    delete "/:website", SiteController, :delete_site

    get "/:website/*path", StatsController, :stats
  end

  def assign_device_id(conn, _opts) do
    if is_nil(Plug.Conn.get_session(conn, :device_id)) do
      Plug.Conn.put_session(conn, :device_id, UUID.uuid4())
    else
      conn
    end
  end
end
