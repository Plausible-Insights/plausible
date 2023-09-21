defmodule PlausibleWeb.Live.ResetPasswordFormTest do
  use PlausibleWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Plausible.Test.Support.HTML

  alias Plausible.Auth.User
  alias Plausible.Auth.Token
  alias Plausible.Repo

  describe "/password/reset" do
    test "sets new password with valid token", %{conn: conn} do
      user = insert(:user)
      token = Token.sign_password_reset(user.email)

      lv = get_liveview(conn, "/password/reset?token=#{token}")

      type_into_passowrd(lv, "very-secret-and-very-long-123")
      html = lv |> element("form") |> render_submit()

      assert [csrf_input, password_input, token_input | _] = find(html, "input")
      assert String.length(text_of_attr(csrf_input, "value")) > 0
      assert text_of_attr(token_input, "value") == token
      assert text_of_attr(password_input, "value") == "very-secret-and-very-long-123"
      assert %{password_hash: new_hash} = Repo.one(User)
      assert new_hash != user.password_hash
    end

    test "renders error when new password fails validation", %{conn: conn} do
      user = insert(:user)
      token = Token.sign_password_reset(user.email)

      lv = get_liveview(conn, "/password/reset?token=#{token}")

      type_into_passowrd(lv, "too-short")
      html = lv |> element("form") |> render_submit()

      assert html =~ "Password is too weak"

      assert %{password_hash: hash} = Repo.one(User)
      assert hash == user.password_hash
    end
  end

  defp get_liveview(conn, url) do
    conn = assign(conn, :live_module, PlausibleWeb.Live.ResetPasswordForm)
    {:ok, lv, _html} = live(conn, url)

    lv
  end

  defp type_into_passowrd(lv, text) do
    lv
    |> element("form")
    |> render_change(%{"user[password]" => text})
  end
end
