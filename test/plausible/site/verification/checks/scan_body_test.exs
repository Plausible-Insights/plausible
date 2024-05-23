defmodule Plausible.Verification.Checks.ScanBodyTest do
  use Plausible.DataCase, async: true

  alias Plausible.Verification.State

  @check Plausible.Verification.Checks.ScanBody

  test "skips on no raw body" do
    state = %State{}
    assert ^state = @check.perform(state)
  end

  test "detects nothing" do
    state =
      %State{}
      |> State.assign(raw_body: "...")
      |> @check.perform()

    refute state.diagnostics.gtm_likely?
    refute state.diagnostics.wordpress_likely?
  end

  test "detects GTM" do
    state =
      %State{}
      |> State.assign(raw_body: "...googletagmanager.com/gtm.js...")
      |> @check.perform()

    assert state.diagnostics.gtm_likely?
    refute state.diagnostics.wordpress_likely?
  end

  for signature <- ["wp-content", "wp-includes", "wp-json"] do
    test "detects WordPress: #{signature}" do
      state =
        %State{}
        |> State.assign(raw_body: "...#{unquote(signature)}...")
        |> @check.perform()

      refute state.diagnostics.gtm_likely?
      assert state.diagnostics.wordpress_likely?
      refute state.diagnostics.wordpress_plugin?
    end
  end

  test "detects GTM and WordPress" do
    state =
      %State{}
      |> State.assign(raw_body: "...googletagmanager.com/gtm.js....wp-content...")
      |> @check.perform()

    assert state.diagnostics.gtm_likely?
    assert state.diagnostics.wordpress_likely?
    refute state.diagnostics.wordpress_plugin?
  end

  @d """
  <meta name='plausible-analytics-version' content='2.0.9' />
  """

  test "detects official plugin" do
    state =
      %State{}
      |> State.assign(raw_body: @d, document: Floki.parse_document!(@d))
      |> @check.perform()

    assert state.diagnostics.wordpress_likely?
    assert state.diagnostics.wordpress_plugin?
  end
end
