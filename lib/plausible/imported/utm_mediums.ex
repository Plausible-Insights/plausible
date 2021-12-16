defmodule Plausible.Imported.UtmMediums do
  use Ecto.Schema
  use Plausible.ClickhouseRepo
  import Ecto.Changeset

  @primary_key false
  schema "imported_utm_mediums" do
    field :domain, :string
    field :timestamp, :naive_datetime
    field :utm_medium, :string, default: ""
    field :visitors, :integer
    field :visits, :integer
    field :bounces, :integer
    # Sum total
    field :visit_duration, :integer
  end

  def new(attrs) do
    %__MODULE__{}
    |> cast(
      attrs,
      [
        :domain,
        :timestamp,
        :utm_medium,
        :visitors,
        :visits,
        :bounces,
        :visit_duration
      ],
      empty_values: [nil, ""]
    )
    |> validate_required([
      :domain,
      :timestamp,
      :visitors,
      :visits,
      :bounces,
      :visit_duration
    ])
  end
end
