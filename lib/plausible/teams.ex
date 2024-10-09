defmodule Plausible.Teams do
  @moduledoc """
  Core context of teams.
  """

  import Ecto.Query

  alias __MODULE__
  alias Plausible.Repo

  def with_subscription(team) do
    Repo.preload(team, subscription: last_subscription_query())
  end

  def owned_sites(team) do
    Repo.preload(team, :sites).sites
  end

  @doc """
  Get or create user's team.

  If the user has no non-guest membership yet, an implicit "My Team" team is
  created with them as an owner.

  If the user already has an owner membership in an existing team,
  that team is returned.

  If the user has a non-guest membership other than owner, `:no_team` error
  is returned.
  """
  def get_or_create(user) do
    with {:error, :no_team} <- get_owned_by_user(user) do
      case create_my_team(user) do
        {:ok, team} -> {:ok, team}
        {:error, :exists_already} -> get_owned_by_user(user)
      end
    end
  end

  defp create_my_team(user) do
    Repo.transaction(fn ->
      team =
        "My Team"
        |> Teams.Team.changeset()
        |> Repo.insert!()

      team_membership = Teams.Membership.changeset(team, user, :owner)

      case Repo.insert(team_membership) do
        {:ok, _} ->
          team

        {:error, %{errors: [user_id: {"has already been taken", _}]}} ->
          Repo.rollback(:exists_already)
      end
    end)
  end

  defp get_owned_by_user(user) do
    result =
      from(tm in Teams.Membership,
        inner_join: t in assoc(tm, :team),
        where: tm.user_id == ^user.id and tm.role == :owner,
        select: t,
        order_by: t.id
      )
      |> Repo.one()

    case result do
      nil -> {:error, :no_team}
      team -> {:ok, team}
    end
  end

  defp last_subscription_query() do
    from(subscription in Plausible.Billing.Subscription,
      order_by: [desc: subscription.inserted_at],
      limit: 1
    )
  end
end
