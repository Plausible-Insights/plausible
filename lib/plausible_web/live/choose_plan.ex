defmodule PlausibleWeb.Live.ChoosePlan do
  @moduledoc """
  LiveView for upgrading to a plan, or changing an existing plan.
  """
  use Phoenix.LiveView
  use Phoenix.HTML

  require Plausible.Billing.Subscription.Status

  alias PlausibleWeb.Components.Billing.{PlanBox, PlanBenefits, Notice}
  alias Plausible.Users
  alias Plausible.Billing.{Plans, Plan, Quota}

  @contact_link "https://plausible.io/contact"
  @billing_faq_link "https://plausible.io/docs/billing"

  def mount(_params, %{"user_id" => user_id}, socket) do
    socket =
      socket
      |> assign_new(:user, fn ->
        Users.with_subscription(user_id)
      end)
      |> assign_new(:usage, fn %{user: user} ->
        Quota.usage(user, with_features: true)
      end)
      |> assign_new(:last_30_days_usage, fn %{user: user, usage: usage} ->
        case usage do
          %{last_30_days: usage_cycle} -> usage_cycle.total
          _ -> Quota.usage_cycle(user, :last_30_days).total
        end
      end)
      |> assign_new(:owned_plan, fn %{user: %{subscription: subscription}} ->
        Plans.get_regular_plan(subscription, only_non_expired: true)
      end)
      |> assign_new(:owned_tier, fn %{owned_plan: owned_plan} ->
        if owned_plan, do: Map.get(owned_plan, :kind), else: nil
      end)
      |> assign_new(:recommended_tier, fn %{owned_plan: owned_plan, user: user, usage: usage} ->
        if owned_plan || usage.sites == 0, do: nil, else: Plans.suggest_tier(user)
      end)
      |> assign_new(:current_interval, fn %{user: user} ->
        current_user_subscription_interval(user.subscription)
      end)
      |> assign_new(:available_plans, fn %{user: user} ->
        Plans.available_plans_for(user, with_prices: true)
      end)
      |> assign_new(:available_volumes, fn %{available_plans: available_plans} ->
        get_available_volumes(available_plans)
      end)
      |> assign_new(:selected_volume, fn %{
                                           owned_plan: owned_plan,
                                           last_30_days_usage: last_30_days_usage,
                                           available_volumes: available_volumes
                                         } ->
        default_selected_volume(owned_plan, last_30_days_usage, available_volumes)
      end)
      |> assign_new(:selected_interval, fn %{current_interval: current_interval} ->
        current_interval || :monthly
      end)
      |> assign_new(:selected_growth_plan, fn %{
                                                available_plans: available_plans,
                                                selected_volume: selected_volume
                                              } ->
        get_plan_by_volume(available_plans.growth, selected_volume)
      end)
      |> assign_new(:selected_business_plan, fn %{
                                                  available_plans: available_plans,
                                                  selected_volume: selected_volume
                                                } ->
        get_plan_by_volume(available_plans.business, selected_volume)
      end)

    {:ok, socket}
  end

  def render(assigns) do
    growth_plan_to_render =
      assigns.selected_growth_plan || List.last(assigns.available_plans.growth)

    business_plan_to_render =
      assigns.selected_business_plan || List.last(assigns.available_plans.business)

    growth_benefits = PlanBenefits.for_growth(growth_plan_to_render)
    business_benefits = PlanBenefits.for_business(business_plan_to_render, growth_benefits)
    enterprise_benefits = PlanBenefits.for_enterprise(business_benefits)

    assigns =
      assigns
      |> assign(:growth_plan_to_render, growth_plan_to_render)
      |> assign(:business_plan_to_render, business_plan_to_render)
      |> assign(:growth_benefits, growth_benefits)
      |> assign(:business_benefits, business_benefits)
      |> assign(:enterprise_benefits, enterprise_benefits)

    ~H"""
    <div class="bg-gray-100 dark:bg-gray-900 pt-1 pb-12 sm:pb-16 text-gray-900 dark:text-gray-100">
      <div class="mx-auto max-w-7xl px-6 lg:px-20">
        <Notice.subscription_past_due class="pb-6" subscription={@user.subscription} />
        <Notice.subscription_paused class="pb-6" subscription={@user.subscription} />
        <Notice.upgrade_ineligible :if={@usage.sites == 0} />
        <div class="mx-auto max-w-4xl text-center">
          <p class="text-4xl font-bold tracking-tight lg:text-5xl">
            <%= if @owned_plan,
              do: "Change subscription plan",
              else: "Upgrade your account" %>
          </p>
        </div>
        <div class="mt-12 flex flex-col gap-8 lg:flex-row items-center lg:items-baseline">
          <.interval_picker selected_interval={@selected_interval} />
          <.slider_output volume={@selected_volume} available_volumes={@available_volumes} />
          <.slider selected_volume={@selected_volume} available_volumes={@available_volumes} />
        </div>
        <div class="mt-6 isolate mx-auto grid max-w-md grid-cols-1 gap-8 lg:mx-0 lg:max-w-none lg:grid-cols-3">
          <PlanBox.standard
            kind={:growth}
            owned={@owned_tier == :growth}
            recommended={@recommended_tier == :growth}
            plan_to_render={@growth_plan_to_render}
            benefits={@growth_benefits}
            available={!!@selected_growth_plan}
            {assigns}
          />
          <PlanBox.standard
            kind={:business}
            owned={@owned_tier == :business}
            recommended={@recommended_tier == :business}
            plan_to_render={@business_plan_to_render}
            benefits={@business_benefits}
            available={!!@selected_business_plan}
            {assigns}
          />
          <PlanBox.enterprise benefits={@enterprise_benefits} />
        </div>
        <p class="mx-auto mt-8 max-w-2xl text-center text-lg leading-8 text-gray-600 dark:text-gray-400">
          You have used <b><%= PlausibleWeb.AuthView.delimit_integer(@last_30_days_usage) %></b>
          billable pageviews in the last 30 days
        </p>
        <.pageview_limit_notice :if={!@owned_plan} />
        <.help_links />
      </div>
    </div>
    <.slider_styles />
    <PlausibleWeb.Components.Billing.paddle_script />
    """
  end

  def handle_event("set_interval", %{"interval" => interval}, socket) do
    new_interval =
      case interval do
        "yearly" -> :yearly
        "monthly" -> :monthly
      end

    {:noreply, assign(socket, selected_interval: new_interval)}
  end

  def handle_event("slide", %{"slider" => index}, socket) do
    index = String.to_integer(index)
    %{available_plans: available_plans, available_volumes: available_volumes} = socket.assigns

    new_volume =
      if index == length(available_volumes) do
        :enterprise
      else
        Enum.at(available_volumes, index)
      end

    {:noreply,
     assign(socket,
       selected_volume: new_volume,
       selected_growth_plan: get_plan_by_volume(available_plans.growth, new_volume),
       selected_business_plan: get_plan_by_volume(available_plans.business, new_volume)
     )}
  end

  defp default_selected_volume(%Plan{monthly_pageview_limit: limit}, _, _), do: limit

  defp default_selected_volume(_, last_30_days_usage, available_volumes) do
    Enum.find(available_volumes, &(last_30_days_usage < &1)) || :enterprise
  end

  defp current_user_subscription_interval(subscription) do
    case Plans.subscription_interval(subscription) do
      "yearly" -> :yearly
      "monthly" -> :monthly
      _ -> nil
    end
  end

  defp get_plan_by_volume(_, :enterprise), do: nil

  defp get_plan_by_volume(plans, volume) do
    Enum.find(plans, &(&1.monthly_pageview_limit == volume))
  end

  defp interval_picker(assigns) do
    ~H"""
    <div class="lg:flex-1 lg:order-3 lg:justify-end flex">
      <div class="relative">
        <.two_months_free />
        <fieldset class="grid grid-cols-2 gap-x-1 rounded-full bg-white dark:bg-gray-700 p-1 text-center text-sm font-semibold leading-5 shadow dark:ring-gray-600">
          <label
            class={"cursor-pointer rounded-full px-2.5 py-1 text-gray-900 dark:text-white #{if @selected_interval == :monthly, do: "bg-indigo-600 text-white"}"}
            phx-click="set_interval"
            phx-value-interval="monthly"
          >
            <input type="radio" name="frequency" value="monthly" class="sr-only" />
            <span>Monthly</span>
          </label>
          <label
            class={"cursor-pointer rounded-full px-2.5 py-1 text-gray-900 dark:text-white #{if @selected_interval == :yearly, do: "bg-indigo-600 text-white"}"}
            phx-click="set_interval"
            phx-value-interval="yearly"
          >
            <input type="radio" name="frequency" value="yearly" class="sr-only" />
            <span>Yearly</span>
          </label>
        </fieldset>
      </div>
    </div>
    """
  end

  def two_months_free(assigns) do
    ~H"""
    <span class="absolute -right-5 -top-4 whitespace-no-wrap w-max px-2.5 py-0.5 rounded-full text-xs font-medium leading-4 bg-yellow-100 border border-yellow-300 text-yellow-700">
      2 months free
    </span>
    """
  end

  defp slider(assigns) do
    slider_labels =
      Enum.map(
        assigns.available_volumes ++ [:enterprise],
        &format_volume(&1, assigns.available_volumes)
      )

    assigns = assign(assigns, :slider_labels, slider_labels)

    ~H"""
    <form class="max-w-md lg:max-w-none w-full lg:w-1/2 lg:order-2">
      <div class="flex items-baseline space-x-2">
        <span class="text-xs font-medium text-gray-600 dark:text-gray-200">
          <%= List.first(@slider_labels) %>
        </span>
        <div class="flex-1 relative">
          <input
            phx-change="slide"
            id="slider"
            name="slider"
            class="shadow mt-8 dark:bg-gray-600 dark:border-none"
            type="range"
            min="0"
            max={length(@available_volumes)}
            step="1"
            value={
              Enum.find_index(@available_volumes, &(&1 == @selected_volume)) ||
                length(@available_volumes)
            }
            oninput="repositionBubble()"
          />
          <output
            id="slider-bubble"
            class="absolute bottom-[35px] py-[4px] px-[12px] -translate-x-1/2 rounded-md text-white bg-indigo-600 position text-xs font-medium"
            phx-update="ignore"
          />
        </div>
        <span class="text-xs font-medium text-gray-600 dark:text-gray-200">
          <%= List.last(@slider_labels) %>
        </span>
      </div>
    </form>

    <script>
      const SLIDER_LABELS = <%= raw Jason.encode!(@slider_labels) %>

      function repositionBubble() {
        const input = document.getElementById("slider")
        const percentage = Number((input.value / input.max) * 100)
        const bubble = document.getElementById("slider-bubble")

        bubble.innerHTML = SLIDER_LABELS[input.value]
        bubble.style.left = `calc(${percentage}% + (${13.87 - percentage * 0.26}px))`
      }

      repositionBubble()
    </script>
    """
  end

  defp pageview_limit_notice(assigns) do
    ~H"""
    <div class="mt-12 mx-auto mt-6 max-w-2xl">
      <dt>
        <p class="w-full text-center text-gray-900 dark:text-gray-100">
          <span class="text-center font-semibold leading-7">
            What happens if I go over my page views limit?
          </span>
        </p>
      </dt>
      <dd class="mt-3">
        <div class="text-justify leading-7 block text-gray-600 dark:text-gray-100">
          You will never be charged extra for an occasional traffic spike. There are no surprise fees and your card will never be charged unexpectedly.               If your page views exceed your plan for two consecutive months, we will contact you to upgrade to a higher plan for the following month. You will have two weeks to make a decision. You can decide to continue with a higher plan or to cancel your account at that point.
        </div>
      </dd>
    </div>
    """
  end

  defp help_links(assigns) do
    ~H"""
    <div class="mt-8 text-center">
      Questions? <a class="text-indigo-600" href={contact_link()}>Contact us</a>
      or see <a class="text-indigo-600" href={billing_faq_link()}>billing FAQ</a>
    </div>
    """
  end

  defp slider_styles(assigns) do
    ~H"""
    <style>
      input[type="range"] {
        -moz-appearance: none;
        -webkit-appearance: none;
        background: white;
        border-radius: 3px;
        height: 6px;
        width: 100%;
        margin-bottom: 9px;
        outline: none;
      }

      input[type="range"]::-webkit-slider-thumb {
        appearance: none;
        -webkit-appearance: none;
        background-color: #5f48ff;
        background-image: url("data:image/svg+xml;charset=US-ASCII,%3Csvg%20width%3D%2212%22%20height%3D%228%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%3E%3Cpath%20d%3D%22M8%20.5v7L12%204zM0%204l4%203.5v-7z%22%20fill%3D%22%23FFFFFF%22%20fill-rule%3D%22nonzero%22%2F%3E%3C%2Fsvg%3E");
        background-position: center;
        background-repeat: no-repeat;
        border: 0;
        border-radius: 50%;
        cursor: pointer;
        height: 26px;
        width: 26px;
      }

      input[type="range"]::-moz-range-thumb {
        background-color: #5f48ff;
        background-image: url("data:image/svg+xml;charset=US-ASCII,%3Csvg%20width%3D%2212%22%20height%3D%228%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%3E%3Cpath%20d%3D%22M8%20.5v7L12%204zM0%204l4%203.5v-7z%22%20fill%3D%22%23FFFFFF%22%20fill-rule%3D%22nonzero%22%2F%3E%3C%2Fsvg%3E");
        background-position: center;
        background-repeat: no-repeat;
        border: 0;
        border: none;
        border-radius: 50%;
        cursor: pointer;
        height: 26px;
        width: 26px;
      }

      input[type="range"]::-ms-thumb {
        background-color: #5f48ff;
        background-image: url("data:image/svg+xml;charset=US-ASCII,%3Csvg%20width%3D%2212%22%20height%3D%228%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%3E%3Cpath%20d%3D%22M8%20.5v7L12%204zM0%204l4%203.5v-7z%22%20fill%3D%22%23FFFFFF%22%20fill-rule%3D%22nonzero%22%2F%3E%3C%2Fsvg%3E");
        background-position: center;
        background-repeat: no-repeat;
        border: 0;
        border-radius: 50%;
        cursor: pointer;
        height: 26px;
        width: 26px;
      }

      input[type="range"]::-moz-focus-outer {
        border: 0;
      }
    </style>
    """
  end

  defp get_available_volumes(%{business: business_plans, growth: growth_plans}) do
    growth_volumes = Enum.map(growth_plans, & &1.monthly_pageview_limit)
    business_volumes = Enum.map(business_plans, & &1.monthly_pageview_limit)

    (growth_volumes ++ business_volumes)
    |> Enum.uniq()
  end

  attr :volume, :any
  attr :available_volumes, :list

  defp slider_output(assigns) do
    ~H"""
    <output class="lg:w-1/4 lg:order-1 font-medium text-lg text-gray-600 dark:text-gray-200">
      <span :if={@volume != :enterprise}>Up to</span>
      <strong id="slider-value" class="text-gray-900 dark:text-gray-100">
        <%= format_volume(@volume, @available_volumes) %>
      </strong>
      monthly pageviews
    </output>
    """
  end

  defp format_volume(volume, available_volumes) do
    if volume == :enterprise do
      available_volumes
      |> List.last()
      |> PlausibleWeb.StatsView.large_number_format()
      |> Kernel.<>("+")
    else
      PlausibleWeb.StatsView.large_number_format(volume)
    end
  end

  defp contact_link(), do: @contact_link

  defp billing_faq_link(), do: @billing_faq_link
end
