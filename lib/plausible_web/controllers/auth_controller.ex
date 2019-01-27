defmodule PlausibleWeb.AuthController do
  use PlausibleWeb, :controller
  use Plausible.Repo
  alias Plausible.Auth
  require Logger

  plug :require_logged_out when action in [:register_form, :register, :login_form, :login]

  def register_form(conn, _params) do
    if get_session(conn, :current_user_email) do
      redirect(conn, to: "/")
    else
      render(conn, "register_form.html")
    end
  end

  def register(conn, %{"name" => name, "email" => email}) do
    token = Auth.Token.sign_activation(name, email)
    url = PlausibleWeb.Endpoint.url() <> "/claim-activation?token=#{token}"
    Logger.debug(url)
    email_template = PlausibleWeb.Email.activation_email(name, email, url)
    Plausible.Mailer.deliver_now(email_template)
    conn |> render("register_success.html", email: email)
  end

  def claim_activation_link(conn, %{"token" => token}) do
    case Auth.Token.verify_activation(token) do
      {:ok, %{name: name, email: email}} ->
        case Auth.create_user(name, email) do
          {:ok, user} ->
            conn = put_session(conn, :current_user_email, user.email)
            redirect(conn, to: "/sites/new")
          {:error, changeset} ->
            send_resp(conn, 400, inspect(changeset.errors))
        end
      {:error, :expired} ->
        conn |> send_resp(401, "Your login token has expired")
      {:error, _} ->
        conn |> send_resp(400, "Your login token is invalid")
    end
  end

  def login(conn, %{"email" => email}) do
    token = Auth.Token.sign_login(email)
    url = PlausibleWeb.Endpoint.url() <> "/claim-login?token=#{token}"
    Logger.debug(url)
    email_template = PlausibleWeb.Email.login_email(email, url)
    Plausible.Mailer.deliver_now(email_template)
    conn |> render("login_success.html", email: email)
  end

  def login_form(conn, _params) do
    render(conn, "login_form.html")
  end

  def claim_login_link(conn, %{"token" => token}) do
    case Auth.Token.verify_login(token) do
      {:ok, %{email: email}} ->

        case Auth.find_user_by(email: email) do
          nil ->
            send_resp(conn, 401, "User account with email #{email} does not exist. Please sign up to get started.")
          user ->
            conn
            |> put_session(:current_user_email, user.email)
            |> redirect(to: "/")
        end
      {:error, :expired} ->
        conn |> send_resp(401, "Your login token has expired")
      {:error, _} ->
        conn |> send_resp(400, "Your login token is invalid")
    end
  end

  def user_settings(conn, _params) do
    changeset = Auth.User.changeset(conn.assigns[:current_user])
    render(conn, "user_settings.html", changeset: changeset)
  end

  def save_settings(conn, %{"user" => user_params}) do
    changes = Auth.User.changeset(conn.assigns[:current_user], user_params)
    case Repo.update(changes) do
      {:ok, user} ->
        conn
        |> put_flash(:success, "Account settings saved succesfully")
        |> redirect(to: "/settings")
      {:error, changeset} ->
        render(conn, "user_settings.html", changeset: changeset)
    end
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  defp require_logged_out(conn, _opts) do
    cond do
      get_session(conn, :current_user_email) ->
        conn
        |> redirect(to: "/")
        |> Plug.Conn.halt
      :else ->
        conn
    end
  end
end
