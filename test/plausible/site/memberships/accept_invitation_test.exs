defmodule Plausible.Site.Memberships.AcceptInvitationTest do
  use Plausible
  use Plausible.DataCase, async: true
  use Bamboo.Test

  alias Plausible.Site.Memberships.AcceptInvitation

  describe "transfer_ownership/3" do
    for {label, opts} <- [{"cloud", []}, {"selfhosted", [selfhost?: true]}] do
      test "transfers ownership on #{label} instance" do
        site = insert(:site, memberships: [])
        existing_owner = insert(:user)

        existing_membership =
          insert(:site_membership, user: existing_owner, site: site, role: :owner)

        new_owner = insert(:user)

        assert {:ok, new_membership} =
                 AcceptInvitation.transfer_ownership(site, new_owner, unquote(opts))

        assert new_membership.site_id == site.id
        assert new_membership.user_id == new_owner.id
        assert new_membership.role == :owner

        existing_membership = Repo.reload!(existing_membership)
        assert existing_membership.user_id == existing_owner.id
        assert existing_membership.site_id == site.id
        assert existing_membership.role == :admin

        assert_no_emails_delivered()
      end
    end

    for role <- [:viewer, :admin] do
      test "upgrades existing #{role} membership into an owner" do
        existing_owner = insert(:user)
        new_owner = insert(:user)

        site =
          insert(:site,
            memberships: [
              build(:site_membership, user: existing_owner, role: :owner),
              build(:site_membership, user: new_owner, role: unquote(role))
            ]
          )

        assert {:ok, %{id: membership_id}} = AcceptInvitation.transfer_ownership(site, new_owner)

        assert %{role: :admin} =
                 Plausible.Repo.get_by(Plausible.Site.Membership, user_id: existing_owner.id)

        assert %{id: ^membership_id, role: :owner} =
                 Plausible.Repo.get_by(Plausible.Site.Membership, user_id: new_owner.id)
      end
    end

    test "does not degrade or alter trial when accepting ownership transfer by self" do
      owner = insert(:user, trial_expiry_date: nil)
      site = insert(:site, memberships: [build(:site_membership, user: owner, role: :owner)])

      assert {:ok, %{id: membership_id}} = AcceptInvitation.transfer_ownership(site, owner)

      assert %{id: ^membership_id, role: :owner} =
               Plausible.Repo.get_by(Plausible.Site.Membership, user_id: owner.id)

      assert Repo.reload!(owner).trial_expiry_date == nil
    end

    on_full_build do
      test "locks the site if the new owner has no active subscription or trial" do
        existing_owner = insert(:user)

        site =
          insert(:site,
            locked: false,
            memberships: [build(:site_membership, user: existing_owner, role: :owner)]
          )

        new_owner = insert(:user, trial_expiry_date: Date.add(Date.utc_today(), -1))

        assert {:ok, _membership} = AcceptInvitation.transfer_ownership(site, new_owner)

        assert Repo.reload!(site).locked
      end
    end

    test "does not lock the site or set trial expiry date if the instance is selfhosted" do
      existing_owner = insert(:user)

      site =
        insert(:site,
          locked: false,
          memberships: [build(:site_membership, user: existing_owner, role: :owner)]
        )

      new_owner = insert(:user, trial_expiry_date: nil)

      assert {:ok, _membership} =
               AcceptInvitation.transfer_ownership(site, new_owner, selfhost?: true)

      assert Repo.reload!(new_owner).trial_expiry_date == nil
      refute Repo.reload!(site).locked
    end

    on_full_build do
      test "ends trial of the new owner immediately" do
        existing_owner = insert(:user)

        site =
          insert(:site,
            locked: false,
            memberships: [build(:site_membership, user: existing_owner, role: :owner)]
          )

        new_owner = insert(:user, trial_expiry_date: Date.add(Date.utc_today(), 7))

        assert {:ok, _membership} = AcceptInvitation.transfer_ownership(site, new_owner)

        assert Repo.reload!(new_owner).trial_expiry_date == Date.add(Date.utc_today(), -1)
        assert Repo.reload!(site).locked
      end
    end

    on_full_build do
      test "sets user's trial expiry date to yesterday if they don't have one" do
        existing_owner = insert(:user)

        site =
          insert(:site,
            locked: false,
            memberships: [build(:site_membership, user: existing_owner, role: :owner)]
          )

        new_owner = insert(:user, trial_expiry_date: nil)

        assert {:ok, _membership} = AcceptInvitation.transfer_ownership(site, new_owner)

        assert Repo.reload!(new_owner).trial_expiry_date == Date.add(Date.utc_today(), -1)
        assert Repo.reload!(site).locked
      end
    end

    on_full_build do
      test "ends grace period and sends an email about it if new owner is past grace period" do
        existing_owner = insert(:user)

        site =
          insert(:site,
            locked: false,
            memberships: [build(:site_membership, user: existing_owner, role: :owner)]
          )

        new_owner = insert(:user, trial_expiry_date: Date.add(Date.utc_today(), -1))
        insert(:subscription, user: new_owner, next_bill_date: Timex.today())

        new_owner =
          new_owner
          |> Plausible.Auth.GracePeriod.start_changeset(100)
          |> then(fn changeset ->
            grace_period =
              changeset
              |> get_field(:grace_period)
              |> Map.put(:end_date, Date.add(Date.utc_today(), -1))

            change(changeset, grace_period: grace_period)
          end)
          |> Repo.update!()

        assert {:ok, _membership} = AcceptInvitation.transfer_ownership(site, new_owner)

        assert Repo.reload!(new_owner).grace_period.is_over
        assert Repo.reload!(site).locked

        assert_email_delivered_with(
          to: [{"Jane Smith", new_owner.email}],
          subject: "[Action required] Your Plausible dashboard is now locked"
        )
      end
    end
  end

  describe "accept_invitation/3 - invitations" do
    test "converts an invitation into a membership" do
      inviter = insert(:user)
      invitee = insert(:user)
      site = insert(:site, members: [inviter])

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: inviter,
          email: invitee.email,
          role: :admin
        )

      assert {:ok, membership} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, invitee)

      assert membership.site_id == site.id
      assert membership.user_id == invitee.id
      assert membership.role == :admin
      refute Repo.reload(invitation)

      assert_email_delivered_with(
        to: [nil: inviter.email],
        subject:
          "[Plausible Analytics] #{invitee.email} accepted your invitation to #{site.domain}"
      )
    end

    test "does not degrade role when trying to invite self as an owner" do
      user = insert(:user)

      %{memberships: [membership]} =
        site = insert(:site, memberships: [build(:site_membership, user: user, role: :owner)])

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: user,
          email: user.email,
          role: :admin
        )

      assert {:ok, invited_membership} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, user)

      assert invited_membership.id == membership.id
      membership = Repo.reload!(membership)
      assert membership.role == :owner
      assert membership.site_id == site.id
      assert membership.user_id == user.id
      refute Repo.reload(invitation)
    end

    test "handles accepting invitation as already a member gracefully" do
      inviter = insert(:user)
      invitee = insert(:user)
      site = insert(:site, members: [inviter])
      existing_membership = insert(:site_membership, user: invitee, site: site, role: :admin)

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: inviter,
          email: invitee.email,
          role: :viewer
        )

      assert {:ok, new_membership} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, invitee)

      assert existing_membership.id == new_membership.id
      assert existing_membership.user_id == new_membership.user_id
      assert existing_membership.site_id == new_membership.site_id
      assert existing_membership.role == new_membership.role
      assert new_membership.role == :admin
      refute Repo.reload(invitation)
    end

    test "returns an error on non-existent invitation" do
      invitee = insert(:user)

      assert {:error, :invitation_not_found} =
               AcceptInvitation.accept_invitation("does_not_exist", invitee)
    end
  end

  describe "accept_invitation/3 - ownership transfers" do
    for {label, opts} <- [{"cloud", []}, {"selfhosted", [selfhost?: true]}] do
      test "converts an ownership transfer into a membership on #{label} instance" do
        site = insert(:site, memberships: [])
        existing_owner = insert(:user)

        existing_membership =
          insert(:site_membership, user: existing_owner, site: site, role: :owner)

        new_owner = insert(:user)

        invitation =
          insert(:invitation,
            site_id: site.id,
            inviter: existing_owner,
            email: new_owner.email,
            role: :owner
          )

        assert {:ok, new_membership} =
                 AcceptInvitation.accept_invitation(
                   invitation.invitation_id,
                   new_owner,
                   unquote(opts)
                 )

        assert new_membership.site_id == site.id
        assert new_membership.user_id == new_owner.id
        assert new_membership.role == :owner
        refute Repo.reload(invitation)

        existing_membership = Repo.reload!(existing_membership)
        assert existing_membership.user_id == existing_owner.id
        assert existing_membership.site_id == site.id
        assert existing_membership.role == :admin

        assert_email_delivered_with(
          to: [nil: existing_owner.email],
          subject:
            "[Plausible Analytics] #{new_owner.email} accepted the ownership transfer of #{site.domain}"
        )
      end
    end

    for role <- [:viewer, :admin] do
      test "upgrades existing #{role} membership into an owner" do
        existing_owner = insert(:user)
        new_owner = insert(:user)

        site =
          insert(:site,
            memberships: [
              build(:site_membership, user: existing_owner, role: :owner),
              build(:site_membership, user: new_owner, role: unquote(role))
            ]
          )

        invitation =
          insert(:invitation,
            site_id: site.id,
            inviter: existing_owner,
            email: new_owner.email,
            role: :owner
          )

        assert {:ok, %{id: membership_id}} =
                 AcceptInvitation.accept_invitation(invitation.invitation_id, new_owner)

        assert %{role: :admin} =
                 Plausible.Repo.get_by(Plausible.Site.Membership, user_id: existing_owner.id)

        assert %{id: ^membership_id, role: :owner} =
                 Plausible.Repo.get_by(Plausible.Site.Membership, user_id: new_owner.id)

        refute Repo.reload(invitation)
      end
    end

    test "does note degrade or alter trial when accepting ownership transfer by self" do
      owner = insert(:user, trial_expiry_date: nil)
      site = insert(:site, memberships: [build(:site_membership, user: owner, role: :owner)])

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: owner,
          email: owner.email,
          role: :owner
        )

      assert {:ok, %{id: membership_id}} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, owner)

      assert %{id: ^membership_id, role: :owner} =
               Plausible.Repo.get_by(Plausible.Site.Membership, user_id: owner.id)

      assert Repo.reload!(owner).trial_expiry_date == nil
      refute Repo.reload(invitation)
    end

    @tag :full_build_only
    test "locks the site if the new owner has no active subscription or trial" do
      existing_owner = insert(:user)

      site =
        insert(:site,
          locked: false,
          memberships: [build(:site_membership, user: existing_owner, role: :owner)]
        )

      new_owner = insert(:user, trial_expiry_date: Date.add(Date.utc_today(), -1))

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: existing_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:ok, _membership} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, new_owner)

      assert Repo.reload!(site).locked
    end

    test "does not lock the site or set trial expiry date if the instance is selfhosted" do
      existing_owner = insert(:user)

      site =
        insert(:site,
          locked: false,
          memberships: [build(:site_membership, user: existing_owner, role: :owner)]
        )

      new_owner = insert(:user, trial_expiry_date: nil)

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: existing_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:ok, _membership} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, new_owner,
                 selfhost?: true
               )

      assert Repo.reload!(new_owner).trial_expiry_date == nil
      refute Repo.reload!(site).locked
    end

    @tag :full_build_only
    test "ends trial of the new owner immediately" do
      existing_owner = insert(:user)

      site =
        insert(:site,
          locked: false,
          memberships: [build(:site_membership, user: existing_owner, role: :owner)]
        )

      new_owner = insert(:user, trial_expiry_date: Date.add(Date.utc_today(), 7))

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: existing_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:ok, _membership} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, new_owner)

      assert Repo.reload!(new_owner).trial_expiry_date == Date.add(Date.utc_today(), -1)
      assert Repo.reload!(site).locked
    end

    @tag :full_build_only
    test "sets user's trial expiry date to yesterday if they don't have one" do
      existing_owner = insert(:user)

      site =
        insert(:site,
          locked: false,
          memberships: [build(:site_membership, user: existing_owner, role: :owner)]
        )

      new_owner = insert(:user, trial_expiry_date: nil)

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: existing_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:ok, _membership} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, new_owner)

      assert Repo.reload!(new_owner).trial_expiry_date == Date.add(Date.utc_today(), -1)
      assert Repo.reload!(site).locked
    end

    @tag :full_build_only
    test "ends grace period and sends an email about it if new owner is past grace period" do
      existing_owner = insert(:user)

      site =
        insert(:site,
          locked: false,
          memberships: [build(:site_membership, user: existing_owner, role: :owner)]
        )

      new_owner = insert(:user, trial_expiry_date: Date.add(Date.utc_today(), -1))
      insert(:subscription, user: new_owner, next_bill_date: Timex.today())

      new_owner =
        new_owner
        |> Plausible.Auth.GracePeriod.start_changeset(100)
        |> then(fn changeset ->
          grace_period =
            changeset
            |> get_field(:grace_period)
            |> Map.put(:end_date, Date.add(Date.utc_today(), -1))

          change(changeset, grace_period: grace_period)
        end)
        |> Repo.update!()

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: existing_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:ok, _membership} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, new_owner)

      assert Repo.reload!(new_owner).grace_period.is_over
      assert Repo.reload!(site).locked

      assert_email_delivered_with(
        to: [{"Jane Smith", new_owner.email}],
        subject: "[Action required] Your Plausible dashboard is now locked"
      )
    end

    test "does not allow transferring ownership to a non-member user when at team members limit" do
      old_owner = insert(:user, subscription: build(:business_subscription))
      new_owner = insert(:user, subscription: build(:growth_subscription))

      site =
        insert(:site,
          memberships:
            [build(:site_membership, user: old_owner, role: :owner)] ++
              build_list(3, :site_membership, role: :admin)
        )

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: old_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:error, {:over_plan_limits, [:team_member_limit]}} =
               AcceptInvitation.accept_invitation(
                 invitation.invitation_id,
                 new_owner
               )
    end

    test "allows transferring ownership to existing site member when at team members limit" do
      old_owner = insert(:user, subscription: build(:business_subscription))
      new_owner = insert(:user, subscription: build(:growth_subscription))

      site =
        insert(:site,
          memberships:
            [
              build(:site_membership, user: old_owner, role: :owner),
              build(:site_membership, user: new_owner, role: :admin)
            ] ++
              build_list(2, :site_membership, role: :admin)
        )

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: old_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:ok, _} =
               AcceptInvitation.accept_invitation(
                 invitation.invitation_id,
                 new_owner
               )
    end

    test "does not allow transferring ownership when sites limit exceeded" do
      old_owner = insert(:user, subscription: build(:business_subscription))
      new_owner = insert(:user, subscription: build(:growth_subscription))

      insert_list(10, :site, members: [new_owner])

      site = insert(:site, members: [old_owner])

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: old_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:error, {:over_plan_limits, [:site_limit]}} =
               AcceptInvitation.accept_invitation(
                 invitation.invitation_id,
                 new_owner
               )
    end

    test "does not allow transferring ownership without feature access" do
      old_owner = insert(:user, subscription: build(:business_subscription))
      new_owner = insert(:user, subscription: build(:growth_subscription))

      site =
        insert(:site,
          memberships: [build(:site_membership, user: old_owner, role: :owner)],
          props_enabled: true,
          allowed_event_props: ["author"]
        )

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: old_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:error, {:over_plan_limits, [:feature_access]}} =
               AcceptInvitation.accept_invitation(
                 invitation.invitation_id,
                 new_owner
               )
    end

    test "does not allow transferring ownership when pageview limit exceeded" do
      old_owner = insert(:user, subscription: build(:business_subscription))
      new_owner = insert(:user, subscription: build(:growth_subscription))

      new_owner_site = insert(:site, members: [new_owner])
      old_owner_site = insert(:site, members: [old_owner])

      somewhere_last_month = NaiveDateTime.utc_now() |> Timex.shift(days: -5)
      somewhere_penultimate_month = NaiveDateTime.utc_now() |> Timex.shift(days: -35)

      generate_usage_for(new_owner_site, 5_000, somewhere_last_month)
      generate_usage_for(new_owner_site, 1_000, somewhere_penultimate_month)

      generate_usage_for(old_owner_site, 6_000, somewhere_last_month)
      generate_usage_for(old_owner_site, 10_000, somewhere_penultimate_month)

      invitation =
        insert(:invitation,
          site_id: old_owner_site.id,
          inviter: old_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:error, {:over_plan_limits, [:monthly_pageview_limit]}} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, new_owner)
    end

    test "does not allow transferring ownership when many limits exceeded at once" do
      old_owner = insert(:user, subscription: build(:business_subscription))
      new_owner = insert(:user, subscription: build(:growth_subscription))

      insert_list(10, :site, members: [new_owner])

      site =
        insert(:site,
          props_enabled: true,
          allowed_event_props: ["author"],
          memberships:
            [build(:site_membership, user: old_owner, role: :owner)] ++
              build_list(3, :site_membership, role: :admin)
        )

      invitation =
        insert(:invitation,
          site_id: site.id,
          inviter: old_owner,
          email: new_owner.email,
          role: :owner
        )

      assert {:error, {:over_plan_limits, [:team_member_limit, :site_limit, :feature_access]}} =
               AcceptInvitation.accept_invitation(invitation.invitation_id, new_owner)
    end
  end
end
