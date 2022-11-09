defmodule Plausible.Repo.Migrations.AddRateLimitingToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add :ingest_rate_limit_scale_seconds, :integer, null: true
      add :ingest_rate_limit_threshold, :integer, null: true
    end
  end
end
