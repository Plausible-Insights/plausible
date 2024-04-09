defmodule Plausible.DataMigration.SiteImports do
  @moduledoc """
  Site imports migration backfilling SiteImport entries for old imports
  and alters import end dates to match actual end date of respective import stats.


  """

  import Ecto.Query

  alias Plausible.ClickhouseRepo
  alias Plausible.Imported
  alias Plausible.Imported.SiteImport
  alias Plausible.Repo
  alias Plausible.Site

  require Plausible.Imported.SiteImport

  def run(opts \\ []) do
    dry_run? = Keyword.get(opts, :dry_run?, true)

    site_import_query =
      from(i in Imported.SiteImport,
        where: i.site_id == parent_as(:site).id and i.status == ^SiteImport.completed(),
        select: 1
      )

    sites_with_imports =
      from(s in Site,
        as: :site,
        where:
          (not is_nil(s.imported_data) and fragment("?->>'status'", s.imported_data) == "ok") or
            exists(site_import_query)
      )
      |> Repo.all(log: false)

    sites_count = length(sites_with_imports)

    IO.puts("Processing #{sites_count} sites with imports (DRY RUN: #{dry_run?})...")

    for {site, idx} <- Enum.with_index(sites_with_imports) do
      site_imports =
        from(i in Imported.SiteImport,
          where: i.site_id == ^site.id and i.status == ^SiteImport.completed()
        )
        |> Repo.all(log: false)

      IO.puts(
        "Processing site ID #{site.id} (#{idx + 1} / #{sites_count}) (imported_data: #{is_struct(site.imported_data)}, site_imports: #{length(site_imports)})"
      )

      site_imports =
        cond do
          !site.imported_data ->
            IO.puts(
              "No legacy import present. Skipping creating legacy site import for site ID #{site.id}"
            )

            site_imports

          site.imported_data && site.imported_data.status != "ok" ->
            IO.puts(
              "Legacy import is in non-complete state. Skipping creating legacy site import for site ID #{site.id}."
            )

            site_imports

          site.imported_data && not Enum.any?(site_imports, & &1.legacy) ->
            IO.puts("Creating legacy site import entry for site ID #{site.id}")

            # create legacy entry if there's not one yet
            params =
              site.imported_data
              |> Imported.SiteImport.from_legacy()
              |> Map.put(:site_id, site.id)
              |> Map.take([:legacy, :start_date, :end_date, :source, :status, :site_id])

            legacy_site_import =
              %Imported.SiteImport{}
              |> Ecto.Changeset.change(params)
              |> insert!(dry_run?)

            [legacy_site_import | site_imports]

          true ->
            IO.puts("Legacy site import entry for site ID #{site.id} already exists")

            site_imports
        end

      # adjust end date for each site import
      for site_import <- site_imports do
        IO.puts(
          "Adjusting end date for site import #{site_import.id} (site ID #{site.id}, start date: #{site_import.start_date}, end date: #{site_import.end_date})"
        )

        import_ids =
          if site_import.legacy do
            [0, site_import.id]
          else
            [site_import.id]
          end

        end_date = imported_stats_end_date(site.id, import_ids)

        if !end_date do
          IO.puts(
            "Site import #{site_import.id} (site ID #{site.id}) does not have any recorded stats. Removing it."
          )

          if site_import.legacy do
            # sanity check that data is correct
            "ok" = site.imported_data.status

            clear_imported_data(site, dry_run?)
          end

          delete!(site_import, dry_run?)
        else
          case Date.compare(end_date, site_import.end_date) do
            :lt ->
              IO.puts(
                "End date of site import #{site_import.id} (site ID #{site.id}) is adjusted from #{site_import.end_date} to #{end_date}."
              )

              site_import
              |> Ecto.Changeset.change(end_date: end_date)
              |> update!(dry_run?)

              # credo:disable-for-next-line Credo.Check.Refactor.Nesting
              if site_import.legacy do
                # sanity check that data is correct
                "ok" = site.imported_data.status

                site
                |> Ecto.Changeset.change(imported_data: %{end_date: end_date})
                |> update!(dry_run?)
              end

            :eq ->
              IO.puts(
                "End date of site import #{site_import.id} (site ID #{site.id}) is left unadjusted."
              )

            :gt ->
              IO.puts(
                "Site import #{site_import.id} (site ID #{site.id}) computed end date is later than the current one. Skipping."
              )
          end
        end
      end

      IO.puts("Done processing site ID #{site.id}")
    end

    IO.puts("Finished")
  end

  # Exposed for testing purposes
  @doc false
  def imported_stats_end_date(site_id, import_ids) do
    [first_schema | schemas] = Imported.schemas()

    query =
      Enum.reduce(schemas, max_date_query(first_schema, site_id, import_ids), fn schema, query ->
        from(s in subquery(union_all(query, ^max_date_query(schema, site_id, import_ids))))
      end)

    dates = ClickhouseRepo.all(from(q in query, select: q.max_date), log: false)

    if dates != [] do
      case Enum.max(dates, Date) do
        # no stats for this domain yet
        ~D[1970-01-01] ->
          nil

        date ->
          date
      end
    else
      nil
    end
  end

  defp insert!(changeset, false = _dry_run?) do
    Repo.insert!(changeset)
  end

  defp insert!(changeset, true = _dry_run?) do
    if changeset.valid? do
      changeset
      |> Ecto.Changeset.change(id: 0)
      |> Ecto.Changeset.apply_changes()
    else
      raise "Invalid insert: #{inspect(changeset)}"
    end
  end

  defp clear_imported_data(site, false = _dry_run?) do
    Repo.update_all(from(s in Site, where: s.id == ^site.id), set: [imported_data: nil])
  end

  defp clear_imported_data(site, true = _dry_run?) do
    %{site | imported_data: nil}
  end

  defp update!(changeset, false = _dry_run?) do
    Repo.update!(changeset)
  end

  defp update!(changeset, true = _dry_run?) do
    if changeset.valid? do
      Ecto.Changeset.apply_changes(changeset)
    else
      raise "Invalid update: #{inspect(changeset)}"
    end
  end

  defp delete!(entity, false = _dry_run?) do
    Repo.delete!(entity)
  end

  defp delete!(entity, true = _dry_run?) do
    entity
  end

  defp max_date_query(schema, site_id, import_ids) do
    from(q in schema,
      where: q.site_id == ^site_id,
      where: q.import_id in ^import_ids,
      select: %{max_date: fragment("max(?)", q.date)}
    )
  end
end
