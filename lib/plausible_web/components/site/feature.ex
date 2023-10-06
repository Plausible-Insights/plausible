defmodule PlausibleWeb.Components.Site.Feature do
  @moduledoc """
  Phoenix Component for rendering a user-facing feature toggle
  capable of flipping booleans in `Plausible.Site` via the `toggle_feature` controller action.
  """
  use PlausibleWeb, :view

  attr :site, Plausible.Site, required: true
  attr :setting, :atom, required: true
  attr :label, :string, required: true
  attr :conn, Plug.Conn, required: true
  attr :disabled?, :boolean, default: false
  slot :inner_block

  def toggle(assigns) do
    ~H"""
    <div>
      <div class="mt-4 mb-8 flex items-center">
        <.button
          conn={@conn}
          site={@site}
          setting={@setting}
          set_to={!Map.fetch!(@site, @setting)}
          disabled?={@disabled?}
        />

        <span class={[
          "ml-2 text-sm font-medium leading-5 mb-1",
          if(assigns.disabled?,
            do: "text-gray-500 dark:text-gray-300",
            else: "text-gray-900  dark:text-gray-100"
          )
        ]}>
          <%= @label %>
        </span>
      </div>
      <div :if={Map.fetch!(@site, @setting)}>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def target(site, setting, conn, set_to) when is_boolean(set_to) do
    r = conn.request_path
    Routes.site_path(conn, :update_feature_visibility, site.domain, setting, r: r, set: set_to)
  end

  defp button(assigns) do
    ~H"""
    <.form action={target(@site, @setting, @conn, @set_to)} method="put" for={nil}>
      <button
        type="submit"
        class={[
          "relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full transition-colors ease-in-out duration-200 focus:outline-none focus:ring",
          if(assigns.set_to, do: "bg-gray-200 dark:bg-gray-700", else: "bg-indigo-600"),
          if(assigns.disabled?, do: "cursor-not-allowed")
        ]}
        disabled={@disabled?}
      >
        <span
          aria-hidden="true"
          class={[
            "inline-block h-5 w-5 rounded-full bg-white dark:bg-gray-800 shadow transform transition ease-in-out duration-200",
            if(assigns.set_to, do: "translate-x-0", else: "translate-x-5")
          ]}
        />
      </button>
    </.form>
    """
  end
end
