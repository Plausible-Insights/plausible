defmodule Plausible.Props do
  @moduledoc """
  Context module for handling custom event properties.
  """

  import Ecto.Query

  @type prop :: String.t()

  @max_props 300
  def max_props, do: @max_props

  @max_prop_key_length 300
  def max_prop_key_length, do: @max_prop_key_length

  @max_prop_value_length 2000
  def max_prop_value_length, do: @max_prop_value_length

  @spec allow(Plausible.Site.t(), [prop()] | prop()) ::
          {:ok, Plausible.Site.t()} | {:error, Ecto.Changeset.t()}
  def allow(site, prop_or_props) do
    old_props = site.allowed_event_props || []
    new_props = List.wrap(prop_or_props) ++ old_props

    site
    |> changeset(new_props)
    |> Plausible.Repo.update()
  end

  @spec disallow(Plausible.Site.t(), prop()) ::
          {:ok, Plausible.Site.t()} | {:error, Ecto.Changeset.t()}
  def disallow(site, prop) do
    allowed_event_props = site.allowed_event_props || []

    site
    |> changeset(allowed_event_props -- [prop])
    |> Plausible.Repo.update()
  end

  defp changeset(site, props) do
    props =
      props
      |> Enum.map(&String.trim/1)
      |> Enum.uniq()

    site
    |> Ecto.Changeset.change(allowed_event_props: props)
    |> Ecto.Changeset.validate_length(:allowed_event_props, max: @max_props)
    |> Ecto.Changeset.validate_change(:allowed_event_props, fn field, allowed_props ->
      if Enum.all?(allowed_props, &valid?/1),
        do: [],
        else: [{field, "must be between 1 and #{@max_prop_key_length} characters"}]
    end)
  end

  @spec auto_import(Plausible.Site.t()) :: {:ok, Plausible.Site.t()}
  @doc """
  Allows the #{@max_props} most frequent props keys for a specific site over
  the past 6 months.
  """
  def auto_import(%Plausible.Site{} = site) do
    props_to_allow =
      site
      |> suggest_keys_to_allow()
      |> Enum.filter(&valid?/1)

    allow(site, props_to_allow)
  end

  @spec suggest_keys_to_allow(Plausible.Site.t(), non_neg_integer()) :: [String.t()]
  @doc """
  Queries the events table to fetch the #{@max_props} most frequent prop keys
  for a specific site over the past 6 months, excluding keys that are already
  allowed.
  """
  def suggest_keys_to_allow(%Plausible.Site{} = site, limit \\ @max_props) do
    allowed_event_props = site.allowed_event_props || []

    unnested_keys =
      from e in Plausible.ClickhouseEventV2,
        where: e.site_id == ^site.id,
        where: fragment("? > (NOW() - INTERVAL 6 MONTH)", e.timestamp),
        select: %{key: fragment("arrayJoin(?)", field(e, :"meta.key"))}

    Plausible.ClickhouseRepo.all(
      from uk in subquery(unnested_keys),
        where: uk.key not in ^allowed_event_props,
        group_by: uk.key,
        select: uk.key,
        order_by: {:desc, count(uk.key)},
        limit: ^limit
    )
  end

  def enabled_for?(%Plausible.Auth.User{} = user) do
    FunWithFlags.enabled?(:props, for: user)
  end

  defp valid?(key) do
    String.length(key) in 1..@max_prop_key_length
  end
end
