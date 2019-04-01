defmodule PlausibleWeb.AuthController do
  use PlausibleWeb, :controller
  use Plausible.Repo
  alias Plausible.Auth
  require Logger

  plug PlausibleWeb.RequireLoggedOutPlug when action in [:register_form, :register, :login_form, :login]
  plug PlausibleWeb.RequireAccountPlug when action in [:user_settings, :save_settings, :delete_me, :password_form, :set_password]

  def register_form(conn, _params) do
    changeset = Plausible.Auth.User.changeset(%Plausible.Auth.User{})
    Plausible.Tracking.event(conn, "Register: View Form")
    render(conn, "register_form.html", changeset: changeset)
  end

  def register(conn, %{"user" => params}) do
    user = Plausible.Auth.User.changeset(%Plausible.Auth.User{}, params)

    case Ecto.Changeset.apply_action(user, :insert) do
      {:ok, user} ->
        token = Auth.Token.sign_activation(user.name, user.email)
        url = PlausibleWeb.Endpoint.url() <> "/claim-activation?token=#{token}"
        Logger.debug(url)
        email_template = PlausibleWeb.Email.activation_email(user, url)
        Plausible.Mailer.deliver_now(email_template)
        Plausible.Tracking.event(conn, "Register: Submit Form")
        conn |> render("register_success.html", email: user.email)
      {:error, changeset} ->
        render(conn, "register_form.html", changeset: changeset)
    end
  end

  def claim_activation_link(conn, %{"token" => token}) do
    case Auth.Token.verify_activation(token) do
      {:ok, %{name: name, email: email}} ->
        case Auth.create_user(name, email) do
          {:ok, user} ->
            Plausible.Tracking.event(conn, "Register: Activate Account")
            Plausible.Tracking.identify(conn, user.id, %{name: user.name})
            conn
            |> put_session(:current_user_id, user.id)
            |> redirect(to: "/password")
          {:error, changeset} ->
            send_resp(conn, 400, inspect(changeset.errors))
        end
      {:error, :expired} ->
        render_error(conn, 401, "Your token has expired. Please request another activation link.")
      {:error, _} ->
        render_error(conn, 400, "Your token is invalid. Please request another activation link.")
    end
  end

  def password_reset_request_form(conn, _) do
    render(conn, "password_reset_request_form.html")
  end

  def password_reset_request(conn, %{"email" => ""}) do
    render(conn, "password_reset_request_form.html", error: "Please enter an email address")
  end

  def password_reset_request(conn, %{"email" => email}) do
    user = Repo.get_by(Plausible.Auth.User, email: email)

    if user do
      token = Auth.Token.sign_password_reset(email)
      url = PlausibleWeb.Endpoint.url() <> "/password/reset?token=#{token}"
      Logger.debug("PASSWORD RESET LINK: " <> url)
      email_template = PlausibleWeb.Email.password_reset_email(email, url)
      Plausible.Mailer.deliver_now(email_template)
      render(conn, "password_reset_request_success.html", email: email)
    else
      render(conn, "password_reset_request_success.html", email: email)
    end
  end

  def password_reset_form(conn, %{"token" => token}) do
    case Auth.Token.verify_password_reset(token) do
      {:ok, %{email: email}} ->
        render(conn, "password_reset_form.html", token: token)
      {:error, :expired} ->
        render_error(conn, 401, "Your token has expired. Please request another password reset link.")
      {:error, _} ->
        render_error(conn, 401, "Your token is invalid. Please request another password reset link.")
    end
  end

  def password_reset(conn, %{"token" => token, "password" => pw}) do
    case Auth.Token.verify_password_reset(token) do
      {:ok, %{email: email}} ->
        user = Repo.get_by(Auth.User, email: email)
        changeset = Auth.User.set_password(user, pw)
        case Repo.update(changeset) do
          {:ok, _updated} ->
            conn
            |> put_flash(:login_title, "Password updated successfully")
            |> put_flash(:login_instructions, "Please log in with your new credentials")
            |> put_session(:current_user_id, nil)
            |> redirect(to: "/login")
          {:error, changeset} ->
            render(conn, "password_reset_form.html", changeset: changeset, token: token)
        end
      {:error, :expired} ->
        render_error(conn, 401, "Your token has expired. Please request another password reset link.")
      {:error, _} ->
        render_error(conn, 401, "Your token is invalid. Please request another password reset link.")
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    alias Plausible.Auth.Password

    user = Repo.one(
      from u in Plausible.Auth.User,
      where: u.email == ^email
    )

    if user do
      if Password.match?(password, user.password_hash || "") do
        conn
        |> put_session(:current_user_id, user.id)
        |> redirect(to: "/")
      else
        conn |> render("login_form.html", error: "Wrong email or password. Please try again.")
      end
    else
      Password.dummy_calculation()
      conn |> render("login_form.html", error: "Wrong email or password. Please try again.")
    end
  end

  def login_form(conn, _params) do
    render(conn, "login_form.html")
  end

  def password_form(conn, _params) do
    render(conn, "password_form.html")
  end

  def set_password(conn, %{"password" => pw}) do
    changeset = Auth.User.set_password(conn.assigns[:current_user], pw)

    case Repo.update(changeset) do
      {:ok, _user} ->
        redirect(conn, to: "/sites/new")
      {:error, changeset} ->
        render(conn, "password_form.html", changeset: changeset)
    end
  end

  def user_settings(conn, _params) do
    changeset = Auth.User.changeset(conn.assigns[:current_user])
    render(conn, "user_settings.html", changeset: changeset)
  end

  def save_settings(conn, %{"user" => user_params}) do
    changes = Auth.User.changeset(conn.assigns[:current_user], user_params)
    case Repo.update(changes) do
      {:ok, _user} ->
        conn
        |> put_flash(:success, "Account settings saved succesfully")
        |> redirect(to: "/settings")
      {:error, changeset} ->
        render(conn, "user_settings.html", changeset: changeset)
    end
  end

  def delete_me(conn, _params) do
    user = conn.assigns[:current_user] |> Repo.preload(:sites)

    for site_membership <- user.site_memberships do
      Repo.delete!(site_membership)
    end

    for site <- user.sites do
      Repo.delete!(site)
    end

    Repo.delete!(user)

    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  defp render_error(conn, status, message) do
    conn
    |> put_status(status)
    |> put_view(PlausibleWeb.ErrorView)
    |> render("#{status}.html", layout: false, message: message)
  end
end
