defmodule PlausibleWeb.Live.Plugins.API.Settings do
  @moduledoc """
  LiveView allowing listing, creating and revoking Plugins API tokens.
  """

  use PlausibleWeb, :live_view
  use Phoenix.HTML

  alias Plausible.Sites
  alias Plausible.Plugins.API.Tokens
  import PlausibleWeb.Components.Generic

  def mount(_params, %{"domain" => domain} = session, socket) do
    socket =
      socket
      |> assign_new(:site, fn %{current_user: current_user} ->
        Sites.get_for_user!(current_user, domain, [:owner, :admin, :super_admin])
      end)
      |> assign_new(:displayed_tokens, fn %{site: site} ->
        Tokens.list(site)
      end)

    {:ok,
     assign(socket,
       domain: domain,
       add_token?: not is_nil(session["new_token"]),
       token_description: session["new_token"] || ""
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.flash_messages flash={@flash} />

      <%= if @add_token? do %>
        <%= live_render(
          @socket,
          PlausibleWeb.Live.Plugins.API.TokenForm,
          id: "token-form",
          session: %{
            "domain" => @domain,
            "token_description" => @token_description,
            "rendered_by" => self()
          }
        ) %>
      <% end %>

      <div class="mt-4">
        <div class="grid mb-16">
          <div class="mt-4 mr-6 sm:ml-4 sm:mt-0 justify-self-end">
            <PlausibleWeb.Components.Generic.button phx-click="add-token">
              Add Plugin Token
            </PlausibleWeb.Components.Generic.button>
          </div>
        </div>

        <.table :if={not Enum.empty?(@displayed_tokens)} rows={@displayed_tokens}>
          <:thead>
            <.th>Description</.th>
            <.th>Hint</.th>
            <.th hide_on_mobile>Last used</.th>
            <.th invisible>Actions</.th>
          </:thead>
          <:tbody :let={token}>
            <.td>
              <%= token.description %>
            </.td>
            <.td>
              **********<%= token.hint %>
            </.td>
            <.td>
              <%= Plausible.Plugins.API.Token.last_used_humanize(token) %>
            </.td>
            <.td actions>
              <.delete_button
                id={"revoke-token-#{token.id}"}
                phx-click="revoke-token"
                phx-value-token-id={token.id}
                data-confirm="Are you sure you want to revoke this Token? This action cannot be reversed."
              />
            </.td>
          </:tbody>
        </.table>
      </div>
    </div>
    """
  end

  def handle_event("add-token", _params, socket) do
    {:noreply, assign(socket, :add_token?, true)}
  end

  def handle_event("revoke-token", %{"token-id" => token_id}, socket) do
    :ok = Tokens.delete(socket.assigns.site, token_id)
    displayed_tokens = Enum.reject(socket.assigns.displayed_tokens, &(&1.id == token_id))
    {:noreply, assign(socket, add_token?: false, displayed_tokens: displayed_tokens)}
  end

  def handle_info(:cancel_add_token, socket) do
    {:noreply, assign(socket, add_token?: false)}
  end

  def handle_info({:token_added, token}, socket) do
    displayed_tokens = [token | socket.assigns.displayed_tokens]

    socket = put_live_flash(socket, :success, "Plugins Token created successfully")

    {:noreply,
     assign(socket,
       displayed_tokens: displayed_tokens,
       add_token?: false,
       token_description: ""
     )}
  end
end
