defmodule Plausible.PaddleApi.Mock do
  def get_subscription(_) do
    {:ok, %{
      "next_payment" => %{
        "date" => "2019-07-10",
        "amount" => 6
      }
    }}
  end

  def update_subscription(_, %{plan_id: new_plan_id}) do
    {:ok, %{
      "plan_id" => new_plan_id,
      "next_payment" => %{
        "date" => "2019-07-10",
        "amount" => 6
      }
    }}
  end
end
