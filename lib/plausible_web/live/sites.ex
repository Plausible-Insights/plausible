defmodule PlausibleWeb.Live.Sites do
  @moduledoc """
  LiveView for sites index.
  """

  use Phoenix.LiveView
  use Phoenix.HTML

  alias Plausible.Auth
  alias Plausible.Repo
  alias Plausible.Site.Memberships.Invitations
  alias Plausible.Sites

  def mount(params, %{"current_user_id" => user_id}, socket) do
    socket =
      socket
      |> assign_new(:filter_text, fn -> "" end)
      |> assign_new(:params, fn -> params end)
      |> assign_new(:user, fn -> Repo.get!(Auth.User, user_id) end)
      |> load_sites()
      |> assign_new(:needs_to_upgrade, fn %{user: user, sites: sites} ->
        user_owns_sites =
          Enum.any?(sites.entries, fn site -> List.first(site.memberships).role == :owner end) ||
            Auth.user_owns_sites?(user)

        user_owns_sites && Plausible.Billing.check_needs_to_upgrade(user)
      end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div
      x-data={"{selectedInvitation: null, invitationOpen: false, invitations: #{Enum.map(@invitations, &({&1.invitation_id, &1})) |> Enum.into(%{}) |> Jason.encode!}}"}
      @keydown.escape.window="invitationOpen = false"
      class="container pt-6"
    >
      <PlausibleWeb.Live.Components.Visitors.gradient_defs />
      <%= if @needs_to_upgrade == {:needs_to_upgrade, :no_active_subscription} do %>
        <div class="rounded-md bg-yellow-100 p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg
                class="h-5 w-5 text-yellow-400"
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                  clip-rule="evenodd"
                />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-yellow-800">
                Payment required
              </h3>
              <div class="mt-2 text-sm text-yellow-700">
                <p>
                  To access the sites you own, you need to subscribe to a monthly or yearly payment plan. <%= link(
                    "Upgrade now →",
                    to: "/settings",
                    class: "text-sm font-medium text-yellow-800"
                  ) %>
                </p>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <div class="mt-6 pb-5 border-b border-gray-200 dark:border-gray-500 flex items-center justify-between">
        <h2 class="text-2xl font-bold leading-7 text-gray-900 dark:text-gray-100 sm:text-3xl sm:leading-9 sm:truncate flex-shrink-0">
          My Sites
        </h2>
      </div>

      <.search_form filter_text={@filter_text} />

      <ul class="my-6 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <%= if Enum.empty?(@sites.entries ++ @invitations) do %>
          <p class="dark:text-gray-100">You don't have any sites yet</p>
        <% end %>

        <%= for invitation <- @invitations do %>
          <div
            class="group cursor-pointer"
            @click={"invitationOpen = true; selectedInvitation = invitations['#{invitation.invitation_id}']"}
          >
            <li class="col-span-1 bg-white dark:bg-gray-800 rounded-lg shadow p-4 group-hover:shadow-lg cursor-pointer">
              <div class="w-full flex items-center justify-between space-x-4">
                <img
                  src={"/favicon/sources/#{invitation.site.domain}"}
                  onerror="this.onerror=null; this.src='/favicon/sources/placeholder';"
                  class="w-4 h-4 flex-shrink-0 mt-px"
                />
                <div class="flex-1 truncate -mt-px">
                  <h3 class="text-gray-900 font-medium text-lg truncate dark:text-gray-100">
                    <%= invitation.site.domain %>
                  </h3>
                </div>

                <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
                  Pending invitation
                </span>
              </div>
              <div class="pl-8 mt-2 flex items-center justify-between">
                <span class="text-gray-600 dark:text-gray-400 text-sm truncate">
                  <span class="text-gray-800 dark:text-gray-200">
                    <b>
                      <%= PlausibleWeb.StatsView.large_number_format(
                        Map.get(@visitors, invitation.site.domain, 0)
                      ) %>
                    </b>
                    visitor<%= if Map.get(@visitors, invitation.site.domain, 0) != 1 do %>
                      s
                    <% end %>
                    in last 24h
                  </span>
                </span>
              </div>
            </li>
          </div>
        <% end %>

        <%= for site <- @sites.entries do %>
          <div class="relative">
            <%= link(to: "/" <> URI.encode_www_form(site.domain)) do %>
              <li class="col-span-1 bg-white dark:bg-gray-800 rounded-lg shadow p-4 group-hover:shadow-lg cursor-pointer">
                <div class="w-full flex items-center justify-between space-x-4">
                  <.favicon domain={site.domain} />
                  <div class="flex-1 -mt-px w-full">
                    <h3
                      class="text-gray-900 font-medium text-lg truncate dark:text-gray-100"
                      style="width: calc(100% - 4rem)"
                    >
                      <%= site.domain %>
                    </h3>
                  </div>
                </div>
                <div class="pl-8 mt-2 flex items-center justify-between">
                  <span class="text-gray-600 dark:text-gray-400 text-sm truncate">
                    <span class="text-gray-800 dark:text-gray-200">
                      <PlausibleWeb.Live.Components.Visitors.chart site={site} />
                      <b>
                        <%= PlausibleWeb.StatsView.large_number_format(
                          Map.get(@visitors, site.domain, 0)
                        ) %>
                      </b>
                      visitor<%= if Map.get(@visitors, site.domain, 0) != 1 do %>
                        s
                      <% end %>
                      in last 24h
                    </span>
                  </span>
                </div>
              </li>
            <% end %>
            <%= if List.first(site.memberships).role != :viewer do %>
              <%= link(to: "/" <> URI.encode_www_form(site.domain) <> "/settings", class: "absolute top-0 right-0 p-4 mt-1") do %>
                <svg
                  class="w-5 h-5 text-gray-600 dark:text-gray-400 transition hover:text-gray-900 dark:hover:text-gray-100"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    fill-rule="evenodd"
                    d="M11.49 3.17c-.38-1.56-2.6-1.56-2.98 0a1.532 1.532 0 01-2.286.948c-1.372-.836-2.942.734-2.106 2.106.54.886.061 2.042-.947 2.287-1.561.379-1.561 2.6 0 2.978a1.532 1.532 0 01.947 2.287c-.836 1.372.734 2.942 2.106 2.106a1.532 1.532 0 012.287.947c.379 1.561 2.6 1.561 2.978 0a1.533 1.533 0 012.287-.947c1.372.836 2.942-.734 2.106-2.106a1.533 1.533 0 01.947-2.287c1.561-.379 1.561-2.6 0-2.978a1.532 1.532 0 01-.947-2.287c.836-1.372-.734-2.942-2.106-2.106a1.532 1.532 0 01-2.287-.947zM10 13a3 3 0 100-6 3 3 0 000 6z"
                    clip-rule="evenodd"
                  >
                  </path>
                </svg>
              <% end %>
            <% end %>
          </div>
        <% end %>
      </ul>

      <%= if Enum.any?(@invitations) do %>
        <div
          x-cloak
          x-show="invitationOpen"
          class="fixed z-10 inset-0 overflow-y-auto"
          aria-labelledby="modal-title"
          role="dialog"
          aria-modal="true"
        >
          <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div
              x-show="invitationOpen"
              x-transition:enter="transition ease-out duration-300"
              x-transition:enter-start="opacity-0"
              x-transition:enter-end="opacity-100"
              x-transition:leave="transition ease-in duration-200"
              x-transition:leave-start="opacity-100"
              x-transition:leave-end="opacity-0"
              class="fixed inset-0 bg-gray-500 dark:bg-gray-800 bg-opacity-75 dark:bg-opacity-75 transition-opacity"
              aria-hidden="true"
              @click="invitationOpen = false"
            >
            </div>
            <!-- This element is to trick the browser into centering the modal contents. -->
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">
              &#8203;
            </span>

            <div
              x-show="invitationOpen"
              x-transition:enter="transition ease-out duration-300"
              x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
              x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
              x-transition:leave="transition ease-in duration-200"
              x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
              x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
              class="inline-block align-bottom bg-white dark:bg-gray-900 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full"
            >
              <div class="bg-white dark:bg-gray-800 px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                <div class="hidden sm:block absolute top-0 right-0 pt-4 pr-4">
                  <button
                    @click="invitationOpen = false"
                    class="bg-white dark:bg-gray-800 rounded-md text-gray-400 dark:text-gray-500 hover:text-gray-500 dark:hover:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                  >
                    <span class="sr-only">Close</span>
                    <!-- Heroicon name: outline/x -->
                    <svg
                      class="h-6 w-6"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M6 18L18 6M6 6l12 12"
                      />
                    </svg>
                  </button>
                </div>
                <div class="sm:flex sm:items-start">
                  <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-green-100 sm:mx-0 sm:h-10 sm:w-10">
                    <svg
                      class="w-6 h-6 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
                      >
                      </path>
                    </svg>
                  </div>
                  <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                    <h3
                      class="text-lg leading-6 font-medium text-gray-900 dark:text-gray-100"
                      id="modal-title"
                    >
                      Invitation for
                      <span x-text="selectedInvitation && selectedInvitation.site.domain"></span>
                    </h3>
                    <div class="mt-2">
                      <p class="text-sm text-gray-500 dark:text-gray-200">
                        You've been invited to the
                        <span x-text="selectedInvitation && selectedInvitation.site.domain"></span>
                        analytics dashboard as <b
                          class="capitalize"
                          x-text="selectedInvitation && selectedInvitation.role"
                        >Admin</b>.
                      </p>
                      <p
                        x-show="selectedInvitation && selectedInvitation.role === 'owner'"
                        class="mt-2 text-sm text-gray-500 dark:text-gray-200"
                      >
                        If you accept the ownership transfer, you will be responsible for billing going forward.
                        <%= if is_nil(@user.trial_expiry_date) && is_nil(@user.subscription) do %>
                          <br /><br />
                          You will have to enter your card details immediately with no 30-day trial.
                        <% end %>
                        <%= if Plausible.Billing.on_trial?(@user) do %>
                          <br /><br /> NB: Your 30-day free trial will end immediately and
                          <strong>you will have to enter your card details</strong>
                          to keep using Plausible.
                        <% end %>
                      </p>
                    </div>
                  </div>
                </div>
              </div>
              <div class="bg-gray-50 dark:bg-gray-850 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                <button
                  class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-indigo-600 text-base font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-700 sm:ml-3 sm:w-auto sm:text-sm"
                  data-method="post"
                  data-csrf={Plug.CSRFProtection.get_csrf_token()}
                  x-bind:data-to="selectedInvitation && ('/sites/invitations/' + selectedInvitation.invitation_id + '/accept')"
                >
                  Accept &amp; Continue
                </button>
                <button
                  type="button"
                  class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-500 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-850 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
                  data-method="post"
                  data-csrf={Plug.CSRFProtection.get_csrf_token()}
                  x-bind:data-to="selectedInvitation && ('/sites/invitations/' + selectedInvitation.invitation_id + '/reject')"
                >
                  Reject
                </button>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  attr :filter_text, :string, default: ""

  def search_form(assigns) do
    ~H"""
    <div class="border-t border-gray-200 pt-4 sm:flex sm:items-center sm:justify-between">
      <form id="filter-form" phx-change="filter">
        <div class="text-gray-800 text-sm inline-flex items-center">
          <div class="relative rounded-md shadow-sm flex">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
              <Heroicons.magnifying_glass class="feather mr-1 dark:text-gray-300" />
            </div>
            <input
              type="text"
              name="filter-text"
              id="filter-text"
              class="pl-8 shadow-sm dark:bg-gray-900 dark:text-gray-300 focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 dark:border-gray-500 rounded-md dark:bg-gray-800"
              placeholder="Search Sites"
              value={@filter_text}
            />
          </div>

          <Heroicons.backspace
            :if={String.trim(@filter_text) != ""}
            class="feather ml-2 cursor-pointer hover:text-red-500 dark:text-gray-300 dark:hover:text-red-500"
            phx-click="reset-filter-text"
            id="reset-filter"
          />
        </div>
      </form>
      <div class="mt-4 flex sm:ml-4 sm:mt-0">
        <a href="/sites/new" class="button">
          + Add Website
        </a>
      </div>
    </div>
    """
  end

  def favicon(assigns) do
    src = "/favicon/sources/#{assigns.domain}"
    assigns = assign(assigns, :src, src)

    ~H"""
    <img src={@src} class="w-4 h-4 flex-shrink-0 mt-px" />
    """
  end

  def handle_event("filter", %{"filter-text" => filter_text}, socket) do
    socket =
      socket
      |> assign(:filter_text, filter_text)
      |> load_sites(force_refresh?: true)

    {:noreply, socket}
  end

  def handle_event("reset-filter-text", _params, socket) do
    socket =
      socket
      |> assign(:filter_text, "")
      |> load_sites(force_refresh?: true)

    {:noreply, socket}
  end

  defp load_sites(socket, opts \\ []) do
    assign_fn =
      if Keyword.get(opts, :force_refresh?, false) do
        fn socket, param, value_fn ->
          assign(socket, param, value_fn.(socket.assigns))
        end
      else
        &assign_new/3
      end

    socket
    |> assign_fn.(:invitations, fn %{filter_text: filter_text, user: user} ->
      Invitations.list_for_email(user.email, filter_by_domain: filter_text)
    end)
    |> assign_fn.(:sites, fn %{
                               user: user,
                               params: params,
                               invitations: invitations,
                               filter_text: filter_text
                             } ->
      excluded_site_ids = Enum.map(invitations, & &1.site_id)
      Sites.list(user, params, excluded_ids: excluded_site_ids, filter_by_domain: filter_text)
    end)
    |> assign_fn.(:visitors, fn %{sites: sites, invitations: invitations} ->
      Plausible.Stats.Clickhouse.last_24h_visitors(
        sites.entries ++ Enum.map(invitations, & &1.site)
      )
    end)
  end
end
