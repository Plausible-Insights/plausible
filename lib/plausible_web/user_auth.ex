defmodule PlausibleWeb.UserAuth do
  @moduledoc """
  Functions for user session management.

  In it's current shape, both current (legacy) and soon to be implemented (new)
  user sessions are supported side by side.

  Once the token-based sessions are implemented, `create_user_session/1` will
  start returning new token instead of the legacy one. At the same time,
  `put_token_in_session/2` will always set the new token. The legacy token will
  still be accepted from the session cookie. Once 14 days pass (the current time
  window for which session cookie is valid without any activity), the legacy
  cookies won't be accepted anymore (token retrieval will most likely be
  instrumented to confirm the usage falls in the mentioned time window as
  expected) and the logic will be cleaned of branching for legacy session.
  """

  import Ecto.Query, only: [from: 2]

  alias Plausible.Auth
  alias Plausible.Repo
  alias PlausibleWeb.TwoFactor

  alias PlausibleWeb.Router.Helpers, as: Routes

  @spec log_in_user(Plug.Conn.t(), Auth.User.t(), String.t() | nil) :: Plug.Conn.t()
  def log_in_user(conn, user, redirect_path \\ nil) do
    login_dest =
      redirect_path || Plug.Conn.get_session(conn, :login_dest) || Routes.site_path(conn, :index)

    conn
    |> set_user_session(user)
    |> set_logged_in_cookie()
    |> Phoenix.Controller.redirect(external: login_dest)
  end

  @spec log_out_user(Plug.Conn.t()) :: Plug.Conn.t()
  def log_out_user(conn) do
    case get_user_token(conn) do
      {:ok, token} -> remove_user_session(token)
      {:error, _} -> :pass
    end

    if live_socket_id = Plug.Conn.get_session(conn, :live_socket_id) do
      PlausibleWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> clear_logged_in_cookie()
  end

  @spec get_user(Plug.Conn.t() | Auth.UserSession.t() | map()) ::
          {:ok, Auth.User.t()} | {:error, :no_valid_token | :session_not_found | :user_not_found}
  def get_user(%Auth.UserSession{} = user_session) do
    if user = Plausible.Users.with_subscription(user_session.user_id) do
      {:ok, user}
    else
      # NOTE: Only possible in a fringe corner case where user is deleted
      # between retrieving the session and retrieving the user themselves.
      {:error, :user_not_found}
    end
  end

  def get_user(conn_or_session) do
    with {:ok, user_session} <- get_user_session(conn_or_session) do
      get_user(user_session)
    end
  end

  @spec get_user_session(Plug.Conn.t() | map()) ::
          {:ok, map()} | {:error, :no_valid_token | :session_not_found}
  def get_user_session(conn_or_session) do
    with {:ok, token} <- get_user_token(conn_or_session) do
      get_session_by_token(token)
    end
  end

  @doc """
  Sets the `logged_in` cookie share with the static site for determining
  whether client is authenticated.

  As it's a separate cookie, there's a chance it might fall out of sync
  with session cookie state due to manual deletion or premature expiration.
  """
  @spec set_logged_in_cookie(Plug.Conn.t()) :: Plug.Conn.t()
  def set_logged_in_cookie(conn) do
    Plug.Conn.put_resp_cookie(conn, "logged_in", "true",
      http_only: false,
      max_age: 60 * 60 * 24 * 365 * 5000
    )
  end

  defp get_session_by_token({:legacy, user_id}) do
    {:ok, %Auth.UserSession{user_id: user_id}}
  end

  defp get_session_by_token({:new, token}) do
    case Repo.get_by(Auth.UserSession, token: token) do
      %Auth.UserSession{} = user_session -> {:ok, user_session}
      nil -> {:error, :session_not_found}
    end
  end

  defp set_user_session(conn, user) do
    {token, _} = create_user_session(conn, user)

    conn
    |> renew_session()
    |> TwoFactor.Session.clear_2fa_user()
    |> put_token_in_session(token)
  end

  defp renew_session(conn) do
    Phoenix.Controller.delete_csrf_token()

    conn
    |> Plug.Conn.configure_session(renew: true)
    |> Plug.Conn.clear_session()
  end

  defp clear_logged_in_cookie(conn) do
    Plug.Conn.delete_resp_cookie(conn, "logged_in")
  end

  defp put_token_in_session(conn, {:new, token}) do
    conn
    |> Plug.Conn.put_session(:user_token, token)
    |> Plug.Conn.put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end

  defp get_user_token(%Plug.Conn{} = conn) do
    conn
    |> Plug.Conn.get_session()
    |> get_user_token()
  end

  defp get_user_token(session) do
    case Enum.map(["user_token", "current_user_id"], &Map.get(session, &1)) do
      [token, nil] when is_binary(token) -> {:ok, {:new, token}}
      [nil, current_user_id] when is_integer(current_user_id) -> {:ok, {:legacy, current_user_id}}
      [nil, nil] -> {:error, :no_valid_token}
    end
  end

  defp create_user_session(conn, user) do
    device_name = get_device_name(conn)

    user_session =
      user
      |> Auth.UserSession.new_session(device_name)
      |> Repo.insert!()

    {{:new, user_session.token}, user_session}
  end

  defp remove_user_session({:legacy, _}), do: :ok

  defp remove_user_session({:new, token}) do
    Repo.delete_all(from us in Auth.UserSession, where: us.token == ^token)
    :ok
  end

  @unknown_label "Unknown"

  defp get_device_name(%Plug.Conn{} = conn) do
    conn
    |> Plug.Conn.get_req_header("user-agent")
    |> List.first()
    |> get_device_name()
  end

  defp get_device_name(user_agent) when is_binary(user_agent) do
    case UAInspector.parse(user_agent) do
      %UAInspector.Result{client: %UAInspector.Result.Client{name: "Headless Chrome"}} ->
        "Headless Chrome"

      %UAInspector.Result.Bot{name: name} when is_binary(name) ->
        name

      %UAInspector.Result{} = ua ->
        browser = browser_name(ua)

        if os = os_name(ua) do
          browser <> " (#{os})"
        else
          browser
        end

      _ ->
        @unknown_label
    end
  end

  defp get_device_name(_), do: @unknown_label

  defp browser_name(ua) do
    case ua.client do
      :unknown -> @unknown_label
      %UAInspector.Result.Client{name: "Mobile Safari"} -> "Safari"
      %UAInspector.Result.Client{name: "Chrome Mobile"} -> "Chrome"
      %UAInspector.Result.Client{name: "Chrome Mobile iOS"} -> "Chrome"
      %UAInspector.Result.Client{name: "Firefox Mobile"} -> "Firefox"
      %UAInspector.Result.Client{name: "Firefox Mobile iOS"} -> "Firefox"
      %UAInspector.Result.Client{name: "Opera Mobile"} -> "Opera"
      %UAInspector.Result.Client{name: "Opera Mini"} -> "Opera"
      %UAInspector.Result.Client{name: "Opera Mini iOS"} -> "Opera"
      %UAInspector.Result.Client{name: "Yandex Browser Lite"} -> "Yandex Browser"
      %UAInspector.Result.Client{name: "Chrome Webview"} -> "Mobile App"
      %UAInspector.Result.Client{type: "mobile app"} -> "Mobile App"
      client -> client.name || @unknown_label
    end
  end

  defp os_name(ua) do
    case ua.os do
      :unknown -> nil
      os -> os.name
    end
  end
end
