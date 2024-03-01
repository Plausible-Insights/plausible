defmodule Plausible.Imported do
  @moduledoc """
  Context for managing site statistics imports.

  Currently following importers are implemented:

  * `Plausible.Imported.UniversalAnalytics` - existing mechanism, for legacy Google
    analytics formerly known as "Google Analytics"
  * `Plausible.Imported.NoopImporter` - importer stub, used mainly for testing purposes
  * `Plausible.Imported.CSVImporter` - CSV importer from S3

  For more information on implementing importers, see `Plausible.Imported.Importer`.
  """

  import Ecto.Query

  alias Plausible.Imported
  alias Plausible.Imported.SiteImport
  alias Plausible.Repo
  alias Plausible.Site

  require Plausible.Imported.SiteImport

  @tables [
    Imported.Visitor,
    Imported.Source,
    Imported.Page,
    Imported.EntryPage,
    Imported.ExitPage,
    Imported.Location,
    Imported.Device,
    Imported.Browser,
    Imported.OperatingSystem
  ]

  @table_names Enum.map(@tables, & &1.__schema__(:source))
  # Maximum number of complete imports to account for when querying stats
  @max_complete_imports 5

  @spec tables() :: [String.t()]
  def tables, do: @table_names

  @spec max_complete_imports() :: non_neg_integer()
  def max_complete_imports(), do: @max_complete_imports

  @spec load_import_data(Site.t()) :: Site.t()
  def load_import_data(%{import_data_loaded: true} = site), do: site

  def load_import_data(site) do
    complete_import_ids = list_complete_import_ids(site)
    earliest_import = get_earliest_import(site) || %{}

    %{
      site
      | import_data_loaded: true,
        earliest_import_start_date: Map.get(earliest_import, :start_date),
        earliest_import_end_date: Map.get(earliest_import, :end_date),
        complete_import_ids: complete_import_ids
    }
  end

  @spec get_import(non_neg_integer()) :: SiteImport.t() | nil
  def get_import(import_id) do
    Repo.get(SiteImport, import_id)
  end

  defdelegate listen(), to: Imported.Importer

  @spec list_all_imports(Site.t()) :: [SiteImport.t()]
  def list_all_imports(site) do
    imports =
      from(i in SiteImport, where: i.site_id == ^site.id, order_by: [desc: i.inserted_at])
      |> Repo.all()

    if site.imported_data && not Enum.any?(imports, & &1.legacy) do
      imports ++ [SiteImport.from_legacy(site.imported_data)]
    else
      imports
    end
  end

  @spec list_complete_import_ids(Site.t()) :: [non_neg_integer()]
  def list_complete_import_ids(site) do
    ids =
      from(i in SiteImport,
        where: i.site_id == ^site.id and i.status == ^SiteImport.completed(),
        select: i.id,
        limit: @max_complete_imports
      )
      |> Repo.all()

    # account for legacy imports as well
    if site.imported_data && site.imported_data.status == "ok" do
      [0 | ids]
    else
      ids
    end
  end

  @spec get_earliest_import(Site.t()) :: SiteImport.t() | nil
  def get_earliest_import(site) do
    first_import =
      from(i in SiteImport,
        where: i.site_id == ^site.id and i.status == ^SiteImport.completed(),
        order_by: i.start_date,
        limit: 1
      )
      |> Repo.one()

    legacy_import =
      if site.imported_data && site.imported_data.status == "ok" do
        site.imported_data
      end

    [legacy_import, first_import]
    |> Enum.reject(&is_nil/1)
    |> Enum.min_by(& &1.start_date, Date, fn -> nil end)
  end

  @spec delete_imports_for_site(Site.t()) :: :ok
  def delete_imports_for_site(site) do
    Repo.delete_all(from i in SiteImport, where: i.site_id == ^site.id)

    :ok
  end
end
