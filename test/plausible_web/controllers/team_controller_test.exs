defmodule PlausibleWeb.TeamControllerTest do
  use PlausibleWeb.ConnCase, async: true
  use Plausible.Repo
  use Plausible.Teams.Test
  use Bamboo.Test

  alias Plausible.Teams

  setup [:create_user, :log_in]

  describe "PUT /team/memberships/u/:id/role/:new_role" do
  end

  describe "DELETE /team/memberships/u/:id" do
  end
end
