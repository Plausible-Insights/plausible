defmodule PlausibleWeb.Site.MembershipController do
  @moduledoc """
    This controller deals with user management via the UI in Site Settings -> People. It's important to enforce permissions in this controller.

    Owner - Can manage users, can trigger a 'transfer ownership' request
    Admin - Can manage users
    Viewer - Can not access user management settings
    Anyone - Can accept invitations

    Everything else should be explicitly disallowed.
  """

  use PlausibleWeb, :controller
  use Plausible.Repo
  use Plausible
  alias Plausible.Sites
  alias Plausible.Site.{Membership, Memberships}
  alias Plausible.Teams

  @only_owner_is_allowed_to [:transfer_ownership_form, :transfer_ownership]

  plug PlausibleWeb.RequireAccountPlug
  plug PlausibleWeb.Plugs.AuthorizeSiteAccess, [:owner] when action in @only_owner_is_allowed_to

  plug PlausibleWeb.Plugs.AuthorizeSiteAccess,
       [:owner, :admin] when action not in @only_owner_is_allowed_to

  def invite_member_form(conn, _params) do
    site =
      conn.assigns.current_user.id
      |> Sites.get_for_user!(conn.assigns.site.domain)
      |> Plausible.Repo.preload(:owner)

    limit = Plausible.Billing.Quota.Limits.team_member_limit(site.owner)
    usage = Plausible.Billing.Quota.Usage.team_member_usage(site.owner)
    below_limit? = Plausible.Billing.Quota.below_limit?(usage, limit)

    render(
      conn,
      "invite_member_form.html",
      site: site,
      team_member_limit: limit,
      is_at_limit: not below_limit?,
      skip_plausible_tracking: true
    )
  end

  def invite_member(conn, %{"email" => email, "role" => role}) do
    site_domain = conn.assigns[:site].domain

    site =
      Sites.get_for_user!(conn.assigns[:current_user].id, site_domain)
      |> Plausible.Repo.preload(:owner)

    case Memberships.create_invitation(site, conn.assigns.current_user, email, role) do
      {:ok, invitation} ->
        conn
        |> put_flash(
          :success,
          "#{email} has been invited to #{site_domain} as #{PlausibleWeb.SiteView.with_indefinite_article("#{invitation.role}")}"
        )
        |> redirect(external: Routes.site_path(conn, :settings_people, site.domain))

      {:error, :already_a_member} ->
        render(conn, "invite_member_form.html",
          error: "Cannot send invite because #{email} is already a member of #{site.domain}",
          site: site,
          skip_plausible_tracking: true
        )

      {:error, {:over_limit, limit}} ->
        render(conn, "invite_member_form.html",
          error:
            "Your account is limited to #{limit} team members. You can upgrade your plan to increase this limit.",
          site: site,
          skip_plausible_tracking: true,
          is_at_limit: true,
          team_member_limit: limit
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        error_msg =
          case changeset.errors[:invitation] do
            {"already sent", _} ->
              "This invitation has been already sent. To send again, remove it from pending invitations first."

            _ ->
              "Something went wrong."
          end

        conn
        |> put_flash(:error, error_msg)
        |> redirect(external: Routes.site_path(conn, :settings_people, site.domain))
    end
  end

  def transfer_ownership_form(conn, _params) do
    site_domain = conn.assigns[:site].domain
    site = Sites.get_for_user!(conn.assigns[:current_user].id, site_domain)

    render(
      conn,
      "transfer_ownership_form.html",
      site: site,
      skip_plausible_tracking: true
    )
  end

  def transfer_ownership(conn, %{"email" => email}) do
    site_domain = conn.assigns[:site].domain
    site = Sites.get_for_user!(conn.assigns[:current_user].id, site_domain)

    case Memberships.create_invitation(site, conn.assigns.current_user, email, :owner) do
      {:ok, _invitation} ->
        conn
        |> put_flash(:success, "Site transfer request has been sent to #{email}")
        |> redirect(external: Routes.site_path(conn, :settings_people, site.domain))

      {:error, :transfer_to_self} ->
        conn
        |> put_flash(:ttl, :timer.seconds(5))
        |> put_flash(:error_title, "Transfer error")
        |> put_flash(:error, "Can't transfer ownership to existing owner")
        |> redirect(external: Routes.site_path(conn, :settings_people, site.domain))

      {:error, changeset} ->
        errors = Plausible.ChangesetHelpers.traverse_errors(changeset)

        message =
          case errors do
            %{invitation: ["already sent" | _]} -> "Invitation has already been sent"
            _other -> "Site transfer request to #{email} has failed"
          end

        conn
        |> put_flash(:ttl, :timer.seconds(5))
        |> put_flash(:error_title, "Transfer error")
        |> put_flash(:error, message)
        |> redirect(external: Routes.site_path(conn, :settings_people, site.domain))
    end
  end

  @doc """
    Updates the role of a user. The user being updated could be the same or different from the user taking
    the action. When updating the role, it's important to enforce permissions:

    Owner - Can update anyone's role except for themselves. If they want to change their own role, they have to use the 'transfer ownership' feature.
    Admin - Can update anyone's role except for owners. Can downgrade their own access to 'viewer'. Can promote a viewer to admin.
  """
  @role_mappings Membership
                 |> Ecto.Enum.mappings(:role)
                 |> Enum.map(fn {k, v} -> {v, k} end)
                 |> Enum.into(%{})

  def update_role(conn, %{"membership_id" => id, "new_role" => new_role_str}) do
    %{site: site, current_user: current_user, current_user_role: current_user_role} = conn.assigns

    membership =
      if Teams.read_team_schemas?(current_user) do
        guest_membership = Teams.Memberships.get_guest_membership(id)

        if guest_membership do
          Membership
          |> Repo.get_by!(user_id: guest_membership.team_membership.user_id, site_id: site.id)
          |> Repo.preload(:user)
        end
      else
        Membership |> Repo.get_by!(id: id, site_id: site.id) |> Repo.preload(:user)
      end

    new_role = Map.fetch!(@role_mappings, new_role_str)

    can_grant_role? =
      if membership.user.id == current_user.id do
        can_grant_role_to_self?(current_user_role, new_role)
      else
        can_grant_role_to_other?(current_user_role, new_role)
      end

    if can_grant_role? do
      membership =
        membership
        |> Ecto.Changeset.change()
        |> Membership.set_role(new_role)
        |> Repo.update!()

      Plausible.Teams.Memberships.update_role_sync(membership)

      redirect_target =
        if membership.user.id == current_user.id and new_role == :viewer do
          "/#{URI.encode_www_form(site.domain)}"
        else
          Routes.site_path(conn, :settings_people, site.domain)
        end

      conn
      |> put_flash(
        :success,
        "#{membership.user.name} is now #{PlausibleWeb.SiteView.with_indefinite_article(new_role_str)}"
      )
      |> redirect(external: redirect_target)
    else
      conn
      |> put_flash(:error, "You are not allowed to grant the #{new_role} role")
      |> redirect(external: Routes.site_path(conn, :settings_people, site.domain))
    end
  end

  defp can_grant_role_to_self?(:admin, :viewer), do: true
  defp can_grant_role_to_self?(_, _), do: false

  defp can_grant_role_to_other?(:owner, :admin), do: true
  defp can_grant_role_to_other?(:owner, :viewer), do: true
  defp can_grant_role_to_other?(:admin, :admin), do: true
  defp can_grant_role_to_other?(:admin, :viewer), do: true
  defp can_grant_role_to_other?(_, _), do: false

  def remove_member(conn, %{"membership_id" => id} = _params) do
    current_user = conn.assigns.current_user
    site = conn.assigns.site

    membership_id =
      if Teams.read_team_schemas?(current_user) do
        guest_membership =
          Teams.Memberships.get_guest_membership(id)

        if guest_membership do
          (Repo.get_by(Membership,
             user_id: guest_membership.team_membership.user_id,
             site_id: site.id
           ) || %{id: 0}).id
        end
      else
        id
      end

    membership_q =
      from m in Membership,
        where: m.id == ^membership_id,
        where: m.site_id == ^site.id,
        inner_join: user in assoc(m, :user),
        inner_join: site in assoc(m, :site),
        preload: [user: user, site: site]

    membership = Repo.one(membership_q)

    if membership do
      Repo.delete!(membership)

      Plausible.Teams.Memberships.remove_sync(membership)

      membership
      |> PlausibleWeb.Email.site_member_removed()
      |> Plausible.Mailer.send()

      redirect_target =
        if membership.user.id == conn.assigns[:current_user].id do
          "/#{URI.encode_www_form(membership.site.domain)}"
        else
          Routes.site_path(conn, :settings_people, site.domain)
        end

      conn
      |> put_flash(
        :success,
        "#{membership.user.name} has been removed from #{site.domain}"
      )
      |> redirect(external: redirect_target)
    else
      conn
      |> put_flash(
        :error,
        "Failed to find membership to remove"
      )
      |> redirect(external: Routes.site_path(conn, :settings_people, site.domain))
    end
  end
end
