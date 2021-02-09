defmodule Plausible.Workers.CheckUsageTest do
  use Plausible.DataCase
  use Bamboo.Test
  import Double
  import Plausible.TestUtils
  alias Plausible.Workers.CheckUsage
  alias Plausible.Billing.Plans

  setup [:create_user, :create_site]
  @paddle_id_10k Plans.plans()[:monthly][:"10k"][:product_id]

  test "ignores user without subscription" do
    CheckUsage.perform(nil, nil)

    assert_no_emails_delivered()
  end

  test "ignores user with subscription but no usage", %{user: user} do
    insert(:subscription, user: user, paddle_plan_id: @paddle_id_10k)
    CheckUsage.perform(nil, nil)

    assert_no_emails_delivered()
  end

  test "does not send an email if account has been over the limit for one billing month", %{
    user: user
  } do
    billing_stub =
      stub(Plausible.Billing, :last_two_billing_months_usage, fn _user -> {9_000, 11_000} end)

    insert(:subscription, user: user, paddle_plan_id: @paddle_id_10k)
    CheckUsage.perform(nil, nil, billing_stub)

    assert_no_emails_delivered()
  end

  test "sends an email when an account is over their limit for two consecutive billing months", %{
    user: user
  } do
    billing_stub =
      stub(Plausible.Billing, :last_two_billing_months_usage, fn _user -> {11_000, 11_000} end)

    insert(:subscription, user: user, paddle_plan_id: @paddle_id_10k)
    CheckUsage.perform(nil, nil, billing_stub)

    assert_email_delivered_with(
      to: [user],
      subject: "You have outgrown your Plausible subscription tier "
    )
  end
end
