defmodule Plausible.Sites do
  use Plausible.Repo
  alias Plausible.Site.{CustomDomain, SharedLink}

  def create(user, params) do
    count = Enum.count(owned_by(user))
    limit = Plausible.Billing.sites_limit(user)

    if count >= limit do
      {:error, :limit, limit}
    else
      site_changeset = Plausible.Site.changeset(%Plausible.Site{}, params)

      Ecto.Multi.new()
      |> Ecto.Multi.insert(:site, site_changeset)
      |> Ecto.Multi.run(:site_membership, fn repo, %{site: site} ->
        membership_changeset =
          Plausible.Site.Membership.changeset(%Plausible.Site.Membership{}, %{
            site_id: site.id,
            user_id: user.id
          })

        repo.insert(membership_changeset)
      end)
      |> Repo.transaction()
    end
  end

  def create_shared_link(site, name, password \\ nil) do
    changes =
      SharedLink.changeset(
        %SharedLink{
          site_id: site.id,
          slug: Nanoid.generate()
        },
        %{name: name, password: password}
      )

    Repo.insert(changes)
  end

  def shared_link_url(site, link) do
    base = PlausibleWeb.Endpoint.url()
    domain = "/share/#{URI.encode_www_form(site.domain)}"
    base <> domain <> "?auth=" <> link.slug
  end

  def get_for_user!(user_id, domain, roles \\ [:owner, :admin, :viewer]),
    do: Repo.one!(get_for_user_q(user_id, domain, roles))

  def get_for_user(user_id, domain, roles \\ [:owner, :admin, :viewer]),
    do: Repo.one(get_for_user_q(user_id, domain, roles))

  defp get_for_user_q(user_id, domain, roles) do
    from(s in Plausible.Site,
      join: sm in Plausible.Site.Membership,
      on: sm.site_id == s.id,
      where: sm.user_id == ^user_id,
      where: sm.role in ^roles,
      where: s.domain == ^domain,
      select: s
    )
  end

  def has_goals?(site) do
    Repo.exists?(
      from g in Plausible.Goal,
        where: g.domain == ^site.domain
    )
  end

  def is_member?(user_id, site) do
    role(user_id, site) !== nil
  end

  def has_admin_access?(user_id, site) do
    role(user_id, site) in [:admin, :owner]
  end

  def role(user_id, site) do
    Repo.one(
      from sm in Plausible.Site.Membership,
        where: sm.user_id == ^user_id and sm.site_id == ^site.id,
        select: sm.role
    )
  end

  def owned_by(user) do
    Repo.all(
      from s in Plausible.Site,
        join: sm in Plausible.Site.Membership,
        on: sm.site_id == s.id,
        where: sm.role == :owner,
        where: sm.user_id == ^user.id
    )
  end

  def owner_for(site) do
    Repo.one(
      from u in Plausible.Auth.User,
        join: sm in Plausible.Site.Membership,
        on: sm.user_id == u.id,
        where: sm.site_id == ^site.id,
        where: sm.role == :owner
    )
  end

  def add_custom_domain(site, custom_domain) do
    CustomDomain.changeset(%CustomDomain{}, %{
      site_id: site.id,
      domain: custom_domain
    })
    |> Repo.insert()
  end
end
