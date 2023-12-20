defmodule Plausible.Workers.AcceptTrafficUntil do
  @moduledoc """
  A worker meant to be run once a day that sends out e-mail notifications to site
  owners assuming:
    - their sites still receive traffic (i.e. have stats for yesterday)
    - `site.accept_traffic_until` is approaching either tomorrow or exactly in 7 days

  Users having no sites or sites that receive no traffic, won't be notified.
  We make a tiny effort here to make sure we send the same notification at most once a day.
  """
  use Oban.Worker, queue: :check_accept_traffic_until
  import Ecto.Query

  alias Plausible.Auth.User
  alias Plausible.Site
  alias Plausible.Repo
  alias Plausible.ClickhouseRepo

  @impl Oban.Worker
  def perform(_job, today \\ Date.utc_today()) do
    tomorrow = today |> Date.add(+1)
    next_week = today |> Date.add(+7)

    # send at most one notification per user, per day
    sent_today_query =
      from s in "sent_accept_traffic_until_notifications",
        where: s.user_id == parent_as(:user).id and s.sent_on == ^today,
        select: true

    notifications =
      Repo.all(
        from u in User,
          as: :user,
          join: sm in Site.Membership,
          on: sm.user_id == u.id,
          where: sm.role == :owner,
          where: u.accept_traffic_until == ^tomorrow or u.accept_traffic_until == ^next_week,
          where: not exists(sent_today_query),
          select: %{
            id: u.id,
            email: u.email,
            deadline: u.accept_traffic_until,
            site_ids: fragment("array_agg(?.site_id)", sm)
          },
          group_by: u.id
      )

    for notification <- notifications do
      case {has_stats?(notification.site_ids, today), notification.deadline} do
        {true, ^tomorrow} ->
          notification
          |> store_sent(today)
          |> PlausibleWeb.Email.approaching_accept_traffic_until_tomorrow()
          |> Plausible.Mailer.send()

        {true, ^next_week} ->
          notification
          |> store_sent(today)
          |> PlausibleWeb.Email.approaching_accept_traffic_until()
          |> Plausible.Mailer.send()

        _ ->
          nil
      end
    end

    {:ok, Enum.count(notifications)}
  end

  defp has_stats?(site_ids, today) do
    yesterday = Date.add(today, -1)

    ClickhouseRepo.exists?(
      from e in "events_v2",
        where: fragment("toDate(?) >= ?", e.timestamp, ^yesterday),
        where: e.site_id in ^site_ids
    )
  end

  defp store_sent(notification, today) do
    Repo.insert_all(
      "sent_accept_traffic_until_notifications",
      [
        %{
          user_id: notification.id,
          sent_on: today
        }
      ],
      on_conflict: :nothing,
      conflict_target: [:user_id, :sent_on]
    )

    notification
  end
end
