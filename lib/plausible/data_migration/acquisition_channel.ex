defmodule Plausible.DataMigration.AcquisitionChannel do
  @moduledoc """
  Creates functions to calculate acquisition channel in ClickHouse

  SQL files available at: priv/data_migrations/AcquisitionChannel/sql
  """
  use Plausible.DataMigration, dir: "AcquisitionChannel", repo: Plausible.IngestRepo

  def run(opts \\ []) do
    source_categories =
      Plausible.Ingestion.Acquisition.source_categories()
      |> invert_map()

    on_cluster_statement = Plausible.MigrationUtils.on_cluster_statement("sessions_v2")

    run_sql_multi(
      "acquisition_channel_functions",
      [
        on_cluster_statement: on_cluster_statement
      ],
      params: %{
        "source_category_shopping" => source_categories["SOURCE_CATEGORY_SHOPPING"],
        "source_category_social" => source_categories["SOURCE_CATEGORY_SOCIAL"],
        "source_category_video" => source_categories["SOURCE_CATEGORY_VIDEO"],
        "source_category_search" => source_categories["SOURCE_CATEGORY_SEARCH"],
        "source_category_email" => source_categories["SOURCE_CATEGORY_EMAIL"],
        "paid_sources" => Plausible.Ingestion.Source.paid_sources()
      },
      quiet: Keyword.get(opts, :quiet, false)
    )
  end

  defp invert_map(source_categories) do
    source_categories
    |> Enum.group_by(
      fn {_source, category} -> category end,
      fn {source, _category} -> source end
    )
  end
end
