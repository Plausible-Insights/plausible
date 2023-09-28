defmodule PlausibleWeb.Plugins.API.Context.SharedLinks do
  @moduledoc """
  Plugins API Context module for Shared Links.
  All high level Shared Links operations should be implemented here.
  """
  import Ecto.Query
  import Plausible.Plugins.API.Pagination

  alias Plausible.Repo

  @spec get_shared_links(Plausible.Site.t(), map()) :: {:ok, Paginator.Page.t()}
  def get_shared_links(site, params) do
    query =
      from l in Plausible.Site.SharedLink,
        where: l.site_id == ^site.id,
        order_by: [desc: l.id]

    {:ok, paginate(query, params, cursor_fields: [{:id, :desc}])}
  end

  @spec get(Plausible.Site.t(), pos_integer() | String.t()) :: nil | Plausible.Site.SharedLink.t()
  def get(site, id) when is_integer(id) do
    get_by_id(site, id)
  end

  def get(site, name) when is_binary(name) do
    get_by_name(site, name)
  end

  @spec get_or_create(Plausible.Site.t(), String.t(), String.t() | nil) ::
          {:ok, Plausible.Site.SharedLink.t()}
  def get_or_create(site, name, password \\ nil) do
    case get_by_name(site, name) do
      nil -> Plausible.Sites.create_shared_link(site, name, password)
      shared_link -> {:ok, shared_link}
    end
  end

  defp get_by_id(site, id) do
    Repo.one(
      from l in Plausible.Site.SharedLink,
        where: l.site_id == ^site.id,
        where: l.id == ^id
    )
  end

  defp get_by_name(site, name) do
    Repo.one(
      from l in Plausible.Site.SharedLink,
        where: l.site_id == ^site.id,
        where: l.name == ^name
    )
  end
end
