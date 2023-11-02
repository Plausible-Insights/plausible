import Config

config :plausible,
  ecto_repos: [Plausible.Repo, Plausible.IngestRepo]

config :plausible, PlausibleWeb.Endpoint,
  # Does not to have to be secret, as per: https://github.com/phoenixframework/phoenix/issues/2146
  live_view: [signing_salt: "f+bZg/crMtgjZJJY7X6OwIWc3XJR2C5Y"],
  pubsub_server: Plausible.PubSub,
  render_errors: [
    view: PlausibleWeb.ErrorView,
    layout: {PlausibleWeb.LayoutView, "base_error.html"},
    accepts: ~w(html json)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js js/dashboard.js js/embed.host.js js/embed.content.js --bundle --target=es2017 --loader:.js=jsx --outdir=../priv/static/js),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.3.3",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/css/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :ua_inspector,
  database_path: "priv/ua_inspector",
  remote_release: "66d80de32fbb265941f4d7941fadc19097375097"

config :ref_inspector,
  database_path: "priv/ref_inspector"

config :plausible,
  paddle_api: Plausible.Billing.PaddleApi,
  google_api: Plausible.Google.Api

config :plausible,
  # 30 minutes
  session_timeout: 1000 * 60 * 30,
  session_length_minutes: 30

config :fun_with_flags, :cache_bust_notifications, enabled: false

config :fun_with_flags, :persistence,
  adapter: FunWithFlags.Store.Persistent.Ecto,
  repo: Plausible.Repo

config :plausible, Plausible.ClickhouseRepo, loggers: [Ecto.LogEntry]

config :plausible, Plausible.Repo,
  timeout: 300_000,
  connect_timeout: 300_000,
  handshake_timeout: 300_000

config :plausible,
  sites_by_domain_cache_enabled: true,
  sites_by_domain_cache_refresh_interval_max_jitter: :timer.seconds(5),
  sites_by_domain_cache_refresh_interval: :timer.minutes(15)

config :plausible, Plausible.Ingestion.Counters, enabled: true

config :ex_cldr,
  default_locale: "en",
  default_backend: Plausible.Cldr

import_config "#{config_env()}.exs"
