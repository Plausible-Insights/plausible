defmodule Plausible.Imported.NoopImporter do
  @moduledoc """
  Stub import implementation.
  """

  use Plausible.Imported.Importer

  @name "Noop"

  @impl true
  def name(), do: @name

  @impl true
  def parse_args(opts), do: opts

  @impl true
  def import_data(_site, %{"error" => true}), do: {:error, "Something went wrong"}
  def import_data(_site, _opts), do: :ok
end
