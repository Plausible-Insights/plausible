defmodule Plausible.CrmExtensions do
  @moduledoc """
  Extensions for Kaffy CRM
  """

  use Plausible

  on_ee do
    def javascripts(%{assigns: %{context: "auth", resource: "user", entry: %{} = user}}) do
      [
        Phoenix.HTML.raw("""
        <script type="text/javascript">
          (async () => {
            const response = await fetch("/crm/auth/user/#{user.id}/usage?embed=true")
            const usageHTML = await response.text()
            const cardBody = document.querySelector(".card-body")
            if (cardBody) {
              const usageDOM = document.createElement("div")
              usageDOM.innerHTML = usageHTML
              cardBody.prepend(usageDOM)
            }
          })()
        </script>
        """)
      ]
    end

    def javascripts(%{assigns: %{context: "billing", resource: "enterprise_plan", changeset: %{}}}) do
      [
        Phoenix.HTML.raw("""
        <script type="text/javascript">
          (() => {
            const monthlyPageviewLimitField = document.getElementById("enterprise_plan_monthly_pageview_limit")

            monthlyPageviewLimitField.type = "input"
            monthlyPageviewLimitField.addEventListener("keyup", numberFormatCallback)
            monthlyPageviewLimitField.addEventListener("change", numberFormatCallback)

            monthlyPageviewLimitField.dispatchEvent(new Event("change"))

            function numberFormatCallback(e) {
              const numeric = Number(e.target.value.replace(/[^0-9]/g, ''))
              const value = numeric > 0 ? new Intl.NumberFormat("en-GB").format(numeric) : ''
              e.target.value = value
            }
          })()
        </script>
        """),
        Phoenix.HTML.raw("""
        <script type="text/javascript">
          (async () => {
            const userIdField = document.getElementById("enterprise_plan_user_id") || document.getElementById("user_id")
            let planRequest
            let lastValue = Number(userIdField.value)
            let scheduledCheck

            userIdField.addEventListener("change", async () => {
              if (scheduledCheck) clearTimeout(scheduledCheck)

              scheduledCheck = setTimeout(async () => {
                const currentValue = Number(userIdField.value)
                if (Number.isInteger(currentValue)
                      && currentValue > 0
                      && currentValue != lastValue
                      && !planRequest) {
                  planRequest = await fetch("/crm/billing/user/" + currentValue + "/current_plan")
                  const result = await planRequest.json()

                  fillForm(result)

                  lastValue = currentValue
                  planRequest = null
                }
              }, 300)
            })

            userIdField.dispatchEvent(new Event("change"))

            function fillForm(result) {
              [
                'billing_interval',
                'monthly_pageview_limit',
                'site_limit',
                'team_member_limit',
                'hourly_api_request_limit'
              ].forEach(name => {
                const prefillValue = result[name] || ""
                const field = document.getElementById('enterprise_plan_' + name)

                field.value = prefillValue
                field.dispatchEvent(new Event("change"))
              });

              ['stats_api', 'props', 'funnels', 'revenue_goals'].forEach(feature => {
                const checked = result.features.includes(feature)
                document.getElementById('enterprise_plan_features_' + feature).checked = checked
              });
            }
          })()
        </script>
        """)
      ]
    end
  end

  def javascripts(_) do
    []
  end
end
