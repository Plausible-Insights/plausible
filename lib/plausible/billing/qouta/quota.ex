defmodule Plausible.Billing.Quota do
  @moduledoc """
  This module provides functions to work with plans usage and limits.
  """

  use Plausible
  alias Plausible.Users
  alias Plausible.Auth.User
  alias Plausible.Billing.{Plan, Plans, EnterprisePlan}
  alias Plausible.Billing.Quota.{Usage, Limits}

  @doc """
  Enterprise plans are always allowed to add more sites (even when
  over limit) to avoid service disruption. Their usage is checked
  in a background job instead (see `check_usage.ex`).
  """
  def ensure_can_add_new_site(user) do
    user = Users.with_subscription(user)

    case Plans.get_subscription_plan(user.subscription) do
      %EnterprisePlan{} ->
        :ok

      _ ->
        usage = Usage.site_usage(user)
        limit = Limits.site_limit(user)

        if below_limit?(usage, limit), do: :ok, else: {:error, {:over_limit, limit}}
    end
  end

  @doc """
  Ensures that the given user (or the usage map) is within the limits
  of the given plan.

  An `opts` argument can be passed with `ignore_pageview_limit: true`
  which bypasses the pageview limit check and returns `:ok` as long as
  the other limits are not exceeded.
  """
  @spec ensure_within_plan_limits(User.t() | map(), struct() | atom() | nil, Keyword.t()) ::
          :ok | {:error, Limits.over_limits_error()}
  def ensure_within_plan_limits(user_or_usage, plan, opts \\ [])

  def ensure_within_plan_limits(%User{} = user, %plan_mod{} = plan, opts)
      when plan_mod in [Plan, EnterprisePlan] do
    ensure_within_plan_limits(Usage.usage(user), plan, opts)
  end

  def ensure_within_plan_limits(usage, %plan_mod{} = plan, opts)
      when plan_mod in [Plan, EnterprisePlan] do
    case exceeded_limits(usage, plan, opts) do
      [] -> :ok
      exceeded_limits -> {:error, {:over_plan_limits, exceeded_limits}}
    end
  end

  def ensure_within_plan_limits(_, _, _), do: :ok

  def eligible_for_upgrade?(usage), do: usage.sites > 0

  defp exceeded_limits(usage, plan, opts) do
    for {limit, exceeded?} <- [
          {:team_member_limit, not within_limit?(usage.team_members, plan.team_member_limit)},
          {:site_limit, not within_limit?(usage.sites, plan.site_limit)},
          {:monthly_pageview_limit,
           exceeds_monthly_pageview_limit?(usage.monthly_pageviews, plan, opts)}
        ],
        exceeded? do
      limit
    end
  end

  defp exceeds_monthly_pageview_limit?(usage, plan, opts) do
    if Keyword.get(opts, :ignore_pageview_limit) do
      false
    else
      case usage do
        %{last_30_days: %{total: total}} ->
          margin = Keyword.get(opts, :pageview_allowance_margin)
          limit = Limits.pageview_limit_with_margin(plan.monthly_pageview_limit, margin)
          !within_limit?(total, limit)

        cycles_usage ->
          exceeds_last_two_usage_cycles?(cycles_usage, plan.monthly_pageview_limit)
      end
    end
  end

  @spec exceeds_last_two_usage_cycles?(Usage.cycles_usage(), non_neg_integer()) :: boolean()
  def exceeds_last_two_usage_cycles?(cycles_usage, allowed_volume) do
    exceeded = exceeded_cycles(cycles_usage, allowed_volume)
    :penultimate_cycle in exceeded && :last_cycle in exceeded
  end

  @spec exceeded_cycles(Usage.cycles_usage(), non_neg_integer()) :: list()
  def exceeded_cycles(cycles_usage, allowed_volume) do
    limit = Limits.pageview_limit_with_margin(allowed_volume)

    Enum.reduce(cycles_usage, [], fn {cycle, %{total: total}}, exceeded_cycles ->
      if below_limit?(total, limit) do
        exceeded_cycles
      else
        exceeded_cycles ++ [cycle]
      end
    end)
  end

  @spec below_limit?(non_neg_integer(), non_neg_integer() | :unlimited) :: boolean()
  @doc """
  Returns whether the usage is below the limit or not.
  Returns false if usage is equal to the limit.
  """
  def below_limit?(usage, limit) do
    if limit == :unlimited, do: true, else: usage < limit
  end

  @spec within_limit?(non_neg_integer(), non_neg_integer() | :unlimited) :: boolean()
  @doc """
  Returns whether the usage is within the limit or not.
  Returns true if usage is equal to the limit.
  """
  def within_limit?(usage, limit) do
    if limit == :unlimited, do: true, else: usage <= limit
  end
end
