defmodule Plausible.Stats.CustomProps do
  @moduledoc """
  Module for querying user defined 'custom properties'.
  """

  alias Plausible.Stats.Query
  use Plausible.ClickhouseRepo
  import Plausible.Stats.Base

  @doc """
  Returns a breakdown of event names with all existing custom
  properties for each event name.
  """
  def props_for_all_event_names(site, query) do
    from(e in base_event_query(site, query),
      array_join: meta in fragment("meta"),
      group_by: e.name,
      select: {e.name, fragment("groupArray(?)", meta.key)},
      distinct: true
    )
    |> ClickhouseRepo.all()
    |> Enum.into(%{})
  end

  def fetch_prop_names(site, query) do
    case Query.get_filter_by_prefix(query, "event:props:") do
      {"event:props:" <> key, _} ->
        [key]

      _ ->
        from(e in base_event_query(site, query),
          array_join: meta in fragment("meta"),
          select: meta.key,
          distinct: true
        )
        |> maybe_allowed_props_only(site.allowed_event_props)
        |> ClickhouseRepo.all()
    end
  end

  def maybe_allowed_props_only(q, allowed_props) when is_list(allowed_props) do
    props = allowed_props ++ Plausible.Props.internal_keys()
    from [..., m] in q, where: m.key in ^props
  end

  def maybe_allowed_props_only(q, nil), do: q
end
