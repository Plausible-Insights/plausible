defmodule PlausibleWeb.EmailView do
  use PlausibleWeb, :view

  def user_salutation(user) do
    if user.name do
      String.split(user.name) |> List.first
    else
      ""
    end
  end

  def suggested_plan_name(usage) do
    cond do
      usage < 9_000 ->
        "Personal"
      usage < 90_000 ->
        "Startup"
      usage < 900_000 ->
        "Business"
      true ->
        throw "Huge account"

    end
  end

  def suggested_plan_cost(usage) do
    cond do
      usage < 9_000 ->
        "$6/mo"
      usage < 90_000 ->
        "$12/mo"
      usage < 900_000 ->
        "$32/mo"
      true ->
        throw "Huge account"

    end
  end
end
