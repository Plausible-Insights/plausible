defmodule PlausibleWeb.AdminControllerTest do
  use PlausibleWeb.ConnCase, async: false

  alias Plausible.Repo

  describe "GET /crm/auth/user/:user_id/usage" do
    setup [:create_user, :log_in]

    @tag :ee_only
    test "returns 403 if the logged in user is not a super admin", %{conn: conn} do
      conn = get(conn, "/crm/auth/user/1/usage")
      assert response(conn, 403) == "Not allowed"
    end

    @tag :ee_only
    test "returns usage data as a standalone page", %{conn: conn, user: user} do
      patch_env(:super_admin_user_ids, [user.id])
      conn = get(conn, "/crm/auth/user/#{user.id}/usage")
      assert response(conn, 200) =~ "<html"
    end

    @tag :ee_only
    test "returns usage data in embeddable form when requested", %{conn: conn, user: user} do
      patch_env(:super_admin_user_ids, [user.id])
      conn = get(conn, "/crm/auth/user/#{user.id}/usage?embed=true")
      refute response(conn, 200) =~ "<html"
    end
  end

  describe "POST /crm/sites/site/:site_id" do
    setup [:create_user, :log_in]

    @tag :ee_only
    test "resets stats start date on native stats start time change", %{conn: conn, user: user} do
      patch_env(:super_admin_user_ids, [user.id])

      site =
        insert(:site,
          public: false,
          stats_start_date: ~D[2022-03-14],
          native_stats_start_at: ~N[2024-01-22 14:28:00]
        )

      params = %{
        "site" => %{
          "domain" => site.domain,
          "timezone" => site.timezone,
          "public" => "false",
          "native_stats_start_at" => "2024-02-12 12:00:00",
          "ingest_rate_limit_scale_seconds" => site.ingest_rate_limit_scale_seconds,
          "ingest_rate_limit_threshold" => site.ingest_rate_limit_threshold
        }
      }

      conn = put(conn, "/crm/sites/site/#{site.id}", params)
      assert redirected_to(conn, 302) == "/crm/sites/site"

      site = Repo.reload!(site)

      refute site.public
      assert site.native_stats_start_at == ~N[2024-02-12 12:00:00]
      assert site.stats_start_date == nil
    end
  end

  describe "GET /crm/billing/user/:user_id/current_plan" do
    setup [:create_user, :log_in]

    @tag :ee_only
    test "returns 403 if the logged in user is not a super admin", %{conn: conn} do
      conn = get(conn, "/crm/billing/user/0/current_plan")
      assert response(conn, 403) == "Not allowed"
    end

    @tag :ee_only
    test "returns empty state for non-existent user", %{conn: conn, user: user} do
      patch_env(:super_admin_user_ids, [user.id])

      conn = get(conn, "/crm/billing/user/0/current_plan")
      assert json_response(conn, 200) == %{"features" => []}
    end

    @tag :ee_only
    test "returns empty state for user without subscription", %{conn: conn, user: user} do
      patch_env(:super_admin_user_ids, [user.id])

      conn = get(conn, "/crm/billing/user/#{user.id}/current_plan")
      assert json_response(conn, 200) == %{"features" => []}
    end

    @tag :ee_only
    test "returns empty state for user with subscription with non-existent paddle plan ID", %{
      conn: conn,
      user: user
    } do
      patch_env(:super_admin_user_ids, [user.id])

      insert(:subscription, user: user)

      conn = get(conn, "/crm/billing/user/#{user.id}/current_plan")
      assert json_response(conn, 200) == %{"features" => []}
    end

    @tag :ee_only
    test "returns plan data for user with subscription", %{conn: conn, user: user} do
      patch_env(:super_admin_user_ids, [user.id])

      insert(:subscription, user: user, paddle_plan_id: "857104")

      conn = get(conn, "/crm/billing/user/#{user.id}/current_plan")

      assert json_response(conn, 200) == %{
               "features" => ["goals"],
               "monthly_pageview_limit" => 10_000_000,
               "site_limit" => 10,
               "team_member_limit" => 3
             }
    end
  end
end
