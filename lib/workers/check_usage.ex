defmodule Plausible.Workers.CheckUsage do
  use Plausible.Repo
  use Oban.Worker, queue: :check_usage
  require Plausible.Billing.Subscription.Status
  alias Plausible.Billing.{Subscription, Quota}
  alias Plausible.Auth.User

  defmacro yesterday() do
    quote do
      fragment("now() - INTERVAL '1 day'")
    end
  end

  defmacro last_day_of_month(day) do
    quote do
      fragment(
        "(date_trunc('month', ?::date) + interval '1 month' - interval '1 day')::date",
        unquote(day)
      )
    end
  end

  defmacro day_of_month(date) do
    quote do
      fragment("EXTRACT(day from ?::date)", unquote(date))
    end
  end

  defmacro least(left, right) do
    quote do
      fragment("least(?, ?)", unquote(left), unquote(right))
    end
  end

  @impl Oban.Worker
  def perform(_job, quota_mod \\ Quota, today \\ Timex.today()) do
    yesterday = today |> Timex.shift(days: -1)

    active_subscribers =
      Repo.all(
        from(u in User,
          join: s in Plausible.Billing.Subscription,
          on: s.user_id == u.id,
          left_join: ep in Plausible.Billing.EnterprisePlan,
          on: ep.user_id == u.id,
          where: s.status == ^Subscription.Status.active(),
          where: not is_nil(s.last_bill_date),
          # Accounts for situations like last_bill_date==2021-01-31 AND today==2021-03-01. Since February never reaches the 31st day, the account is checked on 2021-03-01.
          where:
            least(day_of_month(s.last_bill_date), day_of_month(last_day_of_month(^yesterday))) ==
              day_of_month(^yesterday),
          preload: [subscription: s, enterprise_plan: ep]
        )
      )

    for subscriber <- active_subscribers do
      case {subscriber.grace_period, subscriber.enterprise_plan} do
        {nil, nil} ->
          check_regular_subscriber(subscriber, quota_mod)

        {nil, _} ->
          check_enterprise_subscriber(subscriber, quota_mod)

        {_, nil} ->
          maybe_remove_grace_period(subscriber, quota_mod)

        _ ->
          :skip
      end
    end

    :ok
  end

  @spec exceeds_last_two_usage_cycles?(Quota.monthly_pageview_usage(), non_neg_integer()) ::
          boolean()

  def exceeds_last_two_usage_cycles?(usage, limit) when is_integer(limit) do
    limit = ceil(limit * (1 + Quota.pageview_allowance_margin()))

    Enum.all?([usage.last_cycle, usage.penultimate_cycle], fn usage ->
      not Quota.below_limit?(usage.total, limit)
    end)
  end

  @spec last_usage_cycle_below_limit?(Quota.monthly_pageview_usage(), non_neg_integer()) ::
          boolean()

  def last_usage_cycle_below_limit?(usage, limit) when is_integer(limit) do
    limit = ceil(limit * (1 + Quota.pageview_allowance_margin()))

    Quota.below_limit?(usage.last_cycle.total, limit)
  end

  defp check_site_usage_for_enterprise(subscriber) do
    limit = subscriber.enterprise_plan.site_limit
    usage = Quota.site_usage(subscriber)

    if Quota.below_limit?(usage, limit) do
      {:below_limit, {usage, limit}}
    else
      {:over_limit, {usage, limit}}
    end
  end

  def maybe_remove_grace_period(subscriber, quota_mod) do
    case check_pageview_usage_last_cycle(subscriber, quota_mod) do
      {:below_limit, _} ->
        subscriber
        |> Plausible.Auth.GracePeriod.remove_changeset()
        |> Repo.update()

      _ ->
        :skip
    end
  end

  defp check_regular_subscriber(subscriber, quota_mod) do
    case check_pageview_usage_two_cycles(subscriber, quota_mod) do
      {:over_limit, pageview_usage} ->
        suggested_plan =
          Plausible.Billing.Plans.suggest(subscriber, pageview_usage.last_cycle.total)

        PlausibleWeb.Email.over_limit_email(subscriber, pageview_usage, suggested_plan)
        |> Plausible.Mailer.send()

        subscriber
        |> Plausible.Auth.GracePeriod.start_changeset()
        |> Repo.update()

      _ ->
        nil
    end
  end

  def check_enterprise_subscriber(subscriber, quota_mod) do
    pageview_usage = check_pageview_usage_two_cycles(subscriber, quota_mod)
    site_usage = check_site_usage_for_enterprise(subscriber)

    case {pageview_usage, site_usage} do
      {{:below_limit, _}, {:below_limit, _}} ->
        nil

      {{_, pageview_usage}, {_, {site_usage, site_allowance}}} ->
        PlausibleWeb.Email.enterprise_over_limit_internal_email(
          subscriber,
          pageview_usage,
          site_usage,
          site_allowance
        )
        |> Plausible.Mailer.send()

        subscriber
        |> Plausible.Auth.GracePeriod.start_manual_lock_changeset()
        |> Repo.update()
    end
  end

  defp check_pageview_usage_two_cycles(subscriber, quota_mod) do
    usage = quota_mod.monthly_pageview_usage(subscriber)
    limit = Quota.monthly_pageview_limit(subscriber)

    if exceeds_last_two_usage_cycles?(usage, limit) do
      {:over_limit, usage}
    else
      {:below_limit, usage}
    end
  end

  defp check_pageview_usage_last_cycle(subscriber, quota_mod) do
    usage = quota_mod.monthly_pageview_usage(subscriber)
    limit = Quota.monthly_pageview_limit(subscriber)

    if last_usage_cycle_below_limit?(usage, limit) do
      {:below_limit, usage}
    else
      {:over_limit, usage}
    end
  end
end
