defmodule PlausibleWeb.AuthControllerTest do
  use PlausibleWeb.ConnCase
  use Bamboo.Test

  describe "GET /onboarding" do
    test "shows the register form", %{conn: conn} do
      conn = get(conn, "/register")

      assert html_response(conn, 200) =~ "Enter your details to get started"
    end

    test "registering sends an activation link", %{conn: conn} do
      post(conn, "/register", [name: "Jane Doe", email: "user@example.com"])

      assert_email_delivered_with(subject: "Plausible activation link")
    end

    test "user sees success page after registering", %{conn: conn} do
      conn = post(conn, "/register", [name: "Jane Doe", email: "user@example.com"])

      assert html_response(conn, 200) =~ "Success!"
    end
  end

  describe "GET /claim-activation" do
    test "creates the user", %{conn: conn} do
      token = Plausible.Auth.Token.sign_activation("Jane Doe", "user@example.com")
      get(conn, "/claim-activation?token=#{token}")

      assert Plausible.Auth.find_user_by(email: "user@example.com")
    end

    test "redirects new user to create a site", %{conn: conn} do
      token = Plausible.Auth.Token.sign_activation("Jane Doe", "user@example.com")
      conn = get(conn, "/claim-activation?token=#{token}")

      assert redirected_to(conn) == "/sites/new"
    end

    test "shows error when user with that email already exists", %{conn: conn} do
      token = Plausible.Auth.Token.sign_activation("Jane Doe", "user@example.com")

      conn = get(conn, "/claim-activation?token=#{token}")
      conn = get(conn, "/claim-activation?token=#{token}")

      assert conn.status == 400
    end
  end

  describe "GET /login_form" do
    test "shows the login form", %{conn: conn} do
      conn = get(conn, "/login")
      assert html_response(conn, 200) =~ "Enter your email to log in"
    end

    test "submitting the form sends a login link", %{conn: conn} do
      post(conn, "/login", [email: "user@example.com"])

      assert_email_delivered_with(subject: "Plausible login link")
    end

    test "user sees success page after registering", %{conn: conn} do
      conn = post(conn, "/login", [email: "user@example.com"])

      assert html_response(conn, 200) =~ "Success!"
    end
  end

  def create_user() do
    Plausible.Auth.create_user("Jane Doe", "user@example.com")
  end

  describe "GET /claim-login" do
    setup do
      {:ok, user} = Plausible.Auth.create_user("Jane Doe", "user@example.com")
      {:ok, %{user: user}}
    end

    test "logs the user in", %{conn: conn, user: user} do
      token = Plausible.Auth.Token.sign_login(user.email)
      conn = get(conn, "/claim-login?token=#{token}")

      assert get_session(conn, :current_user_email) == user.email
    end

    test "redirects user to dashboard", %{conn: conn, user: user} do
      token = Plausible.Auth.Token.sign_login(user.email)
      conn = get(conn, "/claim-login?token=#{token}")

      assert redirected_to(conn) == "/"
    end

    test "shows error when user does not exist", %{conn: conn} do
      token = Plausible.Auth.Token.sign_login("nonexistent@user.com")
      conn = get(conn, "/claim-login?token=#{token}")

      assert conn.status == 401
    end
  end
end
