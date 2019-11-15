defmodule PlausibleWeb.Api.StatsController.AuthorizationTest do
  use PlausibleWeb.ConnCase
  import Plausible.TestUtils

  describe "API authorization - as anonymous user" do
    test "Sends 401 unauthorized for a site that doesn't exist", %{conn: conn} do
      conn = init_session(conn)
      conn = get(conn, "/api/stats/fake-site.com/main-graph")

      assert conn.status == 401
    end

    test "Sends 401 unauthorized for private site", %{conn: conn} do
      conn = init_session(conn)
      site = insert(:site, public: false)
      conn = get(conn, "/api/stats/#{site.domain}/main-graph")

      assert conn.status == 401
    end

    test "returns stats for public site", %{conn: conn} do
      conn = init_session(conn)
      site = insert(:site, public: true)
      conn = get(conn, "/api/stats/#{site.domain}/main-graph")

      assert %{"unique_visitors" => _any} = json_response(conn, 200)
    end
  end

  describe "API authorization - as logged in user" do
    setup [:create_user, :log_in]

    test "Sends 401 unauthorized for a site that doesn't exist", %{conn: conn} do
      conn = init_session(conn)
      conn = get(conn, "/api/stats/fake-site.com/main-graph")

      assert conn.status == 401
    end

    test "Sends 401 unauthorized when user does not have access to site", %{conn: conn} do
      site = insert(:site)
      conn = get(conn, "/api/stats/#{site.domain}/main-graph")

      assert conn.status == 401
    end

    test "returns stats for public site", %{conn: conn} do
      site = insert(:site, public: true)
      conn = get(conn, "/api/stats/#{site.domain}/main-graph")

      assert %{"unique_visitors" => _any} = json_response(conn, 200)
    end

    test "returns stats for a private site that the user owns", %{conn: conn, user: user} do
      site = insert(:site, public: false, members: [user])
      conn = get(conn, "/api/stats/#{site.domain}/main-graph")

      assert %{"unique_visitors" => _any} = json_response(conn, 200)
    end
  end
end
