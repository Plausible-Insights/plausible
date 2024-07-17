defmodule Plausible.HelpScout do
  @moduledoc """
  HelpScout callback API logic.
  """

  import Ecto.Query

  alias Plausible.Billing
  alias Plausible.Billing.Subscription
  alias Plausible.HelpScout.Vault
  alias Plausible.Repo

  alias PlausibleWeb.Router.Helpers, as: Routes

  require Plausible.Billing.Subscription.Status

  @base_api_url "https://api.helpscout.net"
  @signature_field "X-HelpScout-Signature"

  @doc """
  Validates signature against secret key configured for the
  HelpScout application.

  NOTE: HelpScout signature generation procedure at
  https://developer.helpscout.com/apps/guides/signature-validation/
  fails to mention that it's implicitly dependent on request params
  order getting preserved. PHP arrays are ordered maps, so they provide
  this guarantee. Here, on the other hand, we have to determine the original
  order of the keys directly from the query string and serialize
  params to JSON using wrapper struct, informing Jason to put the values
  in the serialized object in this particular order matching query string.
  """
  @spec validate_signature(Plug.Conn.t()) :: :ok | {:error, :missing_signature | :bad_signature}
  def validate_signature(conn) do
    params = conn.params

    keys =
      conn.query_string
      |> String.split("&")
      |> Enum.map(fn part ->
        part |> String.split("=") |> List.first()
      end)
      |> Enum.reject(&(&1 == @signature_field))

    signature = params[@signature_field]

    if is_binary(signature) do
      signature_key = Keyword.fetch!(config(), :signature_key)

      ordered_data = Enum.map(keys, fn key -> {key, params[key]} end)
      data = Jason.encode!(%Jason.OrderedObject{values: ordered_data})

      calculated =
        :hmac
        |> :crypto.mac(:sha, signature_key, data)
        |> Base.encode64()

      if Plug.Crypto.secure_compare(signature, calculated) do
        :ok
      else
        {:error, :bad_signature}
      end
    else
      {:error, :missing_signature}
    end
  end

  @spec get_customer_details(String.t()) :: {:ok, map()} | {:error, any()}
  def get_customer_details(customer_id) do
    with {:ok, emails} <- get_customer_emails(customer_id),
         {:ok, user} <- get_user(emails) do
      user = Plausible.Users.with_subscription(user.id)
      plan = Billing.Plans.get_subscription_plan(user.subscription)

      {:ok,
       %{
         status_label: status_label(user),
         status_link:
           Routes.kaffy_resource_url(PlausibleWeb.Endpoint, :show, :auth, :user, user.id),
         plan_label: plan_label(user.subscription, plan),
         plan_link: plan_link(user.subscription),
         sites_count: Plausible.Sites.owned_sites_count(user),
         sites_link:
           Routes.kaffy_resource_url(PlausibleWeb.Endpoint, :index, :sites, :site,
             search: user.email
           )
       }}
    end
  end

  defp plan_link(nil), do: "#"

  defp plan_link(%{paddle_subscription_id: paddle_id}) do
    Path.join([
      Billing.PaddleApi.vendors_domain(),
      "/subscriptions/customers/manage/",
      paddle_id
    ])
  end

  defp status_label(user) do
    subscription_active? = Billing.Subscriptions.active?(user.subscription)
    trial? = Plausible.Users.on_trial?(user)

    cond do
      not subscription_active? and not trial? and is_nil(user.trial_expiry_date) ->
        "None"

      is_nil(user.subscription) and not trial? ->
        "Expired trial"

      trial? ->
        "Trial"

      user.subscription.status == Subscription.Status.deleted() ->
        if subscription_active? do
          "Pending cancellation"
        else
          "Canceled"
        end

      user.subscription.status == Subscription.Status.paused() ->
        "Paused"

      Plausible.Sites.owned_sites_locked?(user) ->
        "Dashboard locked"

      subscription_active? ->
        "Paid"
    end
  end

  defp plan_label(_, nil) do
    "None"
  end

  defp plan_label(_, :free_10k) do
    "Free 10k"
  end

  defp plan_label(subscription, %Billing.Plan{} = plan) do
    [plan] = Billing.Plans.with_prices([plan])
    interval = Billing.Plans.subscription_interval(subscription)
    quota = PlausibleWeb.AuthView.subscription_quota(subscription, [])

    price =
      cond do
        interval == "monthly" && plan.monthly_cost ->
          Billing.format_price(plan.monthly_cost)

        interval == "yearly" && plan.yearly_cost ->
          Billing.format_price(plan.yearly_cost)

        true ->
          "N/A"
      end

    "#{quota} Plan (#{price} #{interval})"
  end

  defp plan_label(subscription, %Billing.EnterprisePlan{} = plan) do
    quota = PlausibleWeb.AuthView.subscription_quota(subscription, [])
    price_amount = Billing.Plans.get_price_for(plan, "127.0.0.1")

    price =
      if price_amount do
        Billing.format_price(price_amount)
      else
        "N/A"
      end

    "#{quota} Enterprise Plan (#{price} #{plan.billing_interval})"
  end

  defp get_user(emails) do
    user =
      from(u in Plausible.Auth.User, where: u.email in ^emails, limit: 1)
      |> Repo.one()

    if user do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end

  defp get_customer_emails(customer_id, opts \\ []) do
    refresh? = Keyword.get(opts, :refresh?, true)
    token = get_token!()

    url = Path.join([@base_api_url, "/v2/customers/", customer_id])

    extra_opts = Application.get_env(:plausible, __MODULE__)[:req_opts] || []
    opts = Keyword.merge([auth: {:bearer, token}], extra_opts)

    case Req.get(url, opts) do
      {:ok, %{body: %{"_embedded" => %{"emails" => [_ | _] = emails}}}} ->
        {:ok, Enum.map(emails, & &1["value"])}

      {:ok, %{status: 200}} ->
        {:error, :no_emails}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: 401}} ->
        if refresh? do
          refresh_token!()
          get_customer_emails(customer_id, refresh?: false)
        else
          {:error, :auth_failed}
        end

      error ->
        Sentry.capture_message("Failed to obtain customer data from HelpScout API",
          extra: %{error: inspect(error), customer_id: customer_id}
        )

        {:error, :unknown}
    end
  end

  defp get_token!() do
    token =
      "SELECT access_token FROM help_scout_credentials ORDER BY id DESC LIMIT 1"
      |> Repo.query!()
      |> Map.get(:rows)
      |> List.first()

    case token do
      [token] when is_binary(token) ->
        Vault.decrypt!(token)

      _ ->
        refresh_token!()
    end
  end

  defp refresh_token!() do
    url = Path.join(@base_api_url, "/v2/oauth2/token")
    credentials = config()

    params = [
      grant_type: "client_credentials",
      client_id: Keyword.fetch!(credentials, :app_id),
      client_secret: Keyword.fetch!(credentials, :app_secret)
    ]

    extra_opts = Application.get_env(:plausible, __MODULE__)[:req_opts] || []
    opts = Keyword.merge([form: params], extra_opts)

    %{status: 200, body: %{"access_token" => token}} = Req.post!(url, opts)
    now = NaiveDateTime.utc_now(:second)

    Repo.insert_all("help_scout_credentials", [
      [access_token: Vault.encrypt!(token), inserted_at: now, updated_at: now]
    ])

    token
  end

  defp config() do
    Application.fetch_env!(:plausible, __MODULE__)
  end
end
