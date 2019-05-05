defmodule Plausible.Billing.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:paddle_subscription_id, :paddle_plan_id, :update_url, :cancel_url, :status, :next_bill_amount, :next_bill_date, :user_id]
  @valid_statuses ["active", "past_due", "deleted"]

  schema "subscriptions" do
    field :paddle_subscription_id, :string
    field :paddle_plan_id, :string
    field :update_url, :string
    field :cancel_url, :string
    field :status, :string
    field :next_bill_amount, :string
    field :next_bill_date, :date

    belongs_to :user, Plausible.Auth.User

    timestamps()
  end

  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @valid_statuses)
    |> unique_constraint(:paddle_subscription_id)
  end
end
