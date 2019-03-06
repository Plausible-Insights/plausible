defmodule PlausibleWeb.SessionTimeoutPlug do
  import Plug.Conn

  def init(opts \\ []) do
    opts
  end

  def call(conn, opts) do
    timeout_at = get_session(conn, :session_timeout_at)
    user_id = get_session(conn, :current_user_id)

    if user_id && timeout_at && now() > timeout_at do
      logout_user(conn)
    else
      put_session(conn, :session_timeout_at, new_session_timeout_at(opts[:timeout_after_seconds]))
    end
  end

  defp logout_user(conn) do
    conn
    |> put_session(:current_user_id, nil) # Leave `device_id` in the session for accurate tracking
    |> assign(:session_timeout, true)
  end

  defp now do
    DateTime.utc_now() |> DateTime.to_unix
  end

  defp new_session_timeout_at(timeout_after_seconds) do
    now() + timeout_after_seconds
  end
end
