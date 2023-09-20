defmodule PlausibleWeb.Live.SetPasswordForm do
  @moduledoc """
  LiveView for password set and reset form.
  """

  use Phoenix.LiveView
  use Phoenix.HTML

  import PlausibleWeb.Live.Components.Form

  alias Plausible.Auth
  alias Plausible.Repo

  def mount(_params, %{"reset_token" => reset_token}, socket) do
    # by that point token should be already verified
    {:ok, %{email: email}} = Auth.Token.verify_password_reset(reset_token)
    user = Repo.get_by!(Auth.User, email: email)
    changeset = Auth.User.changeset(user)

    {:ok,
     assign(socket,
       user: user,
       form: to_form(changeset),
       reset_token: reset_token,
       password_strength: Auth.User.password_strength(changeset),
       trigger_submit: false
     )}
  end

  def mount(_params, %{"current_user_id" => user_id}, socket) do
    user = Repo.get!(Auth.User, user_id)
    changeset = Auth.User.changeset(user)

    {:ok,
     assign(socket,
       user: user,
       form: to_form(changeset),
       reset_token: nil,
       password_strength: Auth.User.password_strength(changeset),
       trigger_submit: false
     )}
  end

  def render(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@form}
      method="post"
      phx-change="validate"
      phx-submit="set"
      phx-trigger-action={@trigger_submit}
      class="bg-white dark:bg-gray-800 max-w-md w-full mx-auto shadow-md rounded px-8 py-6 mt-8"
    >
      <input name="_csrf_token" type="hidden" value={Plug.CSRFProtection.get_csrf_token()} />
      <h2 class="text-xl font-black dark:text-gray-100">
        <%= if @reset_token do %>
          Reset your password
        <% else %>
          Set your password
        <% end %>
      </h2>
      <div class="my-4">
        <.password_length_hint
          minimum={12}
          field={f[:password]}
          class={["text-sm", "mt-1", "mb-2"]}
          ok_class="text-gray-600 dark:text-gray-600"
          error_class="text-red-600 dark:text-red-500"
        />
        <.password_input_with_strength
          field={f[:password]}
          strength={@password_strength}
          phx-debounce={200}
          class="transition bg-gray-100 dark:bg-gray-900 outline-none appearance-none border border-transparent rounded w-full p-2 text-gray-700 dark:text-gray-300 leading-normal appearance-none focus:outline-none focus:bg-white dark:focus:bg-gray-800 focus:border-gray-300 dark:focus:border-gray-500"
        />
      </div>
      <input :if={@reset_token} name="token" type="hidden" value={@reset_token} />
      <button id="set" type="submit" class="button mt-4 w-full">
        Set password →
      </button>
      <p class="text-center text-gray-500 text-xs mt-4">
        Don't have an account? <%= link("Register",
          to: "/register",
          class: "underline text-gray-800 dark:text-gray-200"
        ) %> instead.
      </p>
    </.form>
    """
  end

  def handle_event("validate", %{"user" => %{"password" => password}}, socket) do
    changeset =
      socket.assigns.user
      |> Auth.User.set_password(password)
      |> Map.put(:action, :validate)

    password_strength = Auth.User.password_strength(changeset)

    {:noreply, assign(socket, form: to_form(changeset), password_strength: password_strength)}
  end

  def handle_event("set", %{"user" => %{"password" => password}}, socket) do
    user = Auth.User.set_password(socket.assigns.user, password)

    case Repo.update(user) do
      {:ok, _user} ->
        {:noreply, assign(socket, trigger_submit: true)}

      {:error, changeset} ->
        {:noreply,
         assign(socket,
           form: to_form(Map.put(changeset, :action, :validate))
         )}
    end
  end
end
