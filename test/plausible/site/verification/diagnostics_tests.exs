defmodule Plausible.Verification.DiagnosticsTest do
  use Plausible.DataCase, async: true

  alias Plausible.Verification.Checks
  alias Plausible.Verification.State

  import ExUnit.CaptureLog
  import Plug.Conn

  @normal_body """
  <html>
  <head>
  <script defer data-domain="example.com" src="http://localhost:8000/js/script.js"></script>
  </head>
  <body>Hello</body>
  </html>
  """

  describe "running checks" do
    test "success" do
      stub_fetch_body(200, @normal_body)
      stub_installation()

      result = run_checks()

      rating = Checks.interpret_diagnostics(result)
      assert rating.ok?
      assert rating.errors == []
      assert rating.recommendations == []
    end

    test "service error - 400" do
      stub_fetch_body(200, @normal_body)
      stub_installation(400, %{})

      result = run_checks()

      rating = Checks.interpret_diagnostics(result)

      refute rating.ok?

      assert rating.errors == ["We encountered a temporary problem verifying your website"]

      assert rating.recommendations == [
               {"Please try again in a few minutes or manually check your integration",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end

    @tag :slow
    test "can't fetch body but headless reports ok" do
      stub_fetch_body(500, "")
      stub_installation()

      {result, log} =
        with_log(fn ->
          run_checks()
        end)

      assert log =~ "3 attempts left"
      assert log =~ "2 attempts left"
      assert log =~ "1 attempt left"

      rating = Checks.interpret_diagnostics(result)
      refute rating.ok?
      assert rating.errors == ["We couldn't reach https://example.com. Is your site up?"]

      assert rating.recommendations == [
               {"If your site is running at a different location, please manually check your integration",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end

    test "fetching will follow 2 redirects" do
      ref = :counters.new(1, [:atomics])
      test = self()

      Req.Test.stub(Plausible.Verification.Checks.FetchBody, fn conn ->
        if :counters.get(ref, 1) < 2 do
          :counters.add(ref, 1, 1)
          send(test, :redirect_sent)

          conn
          |> put_resp_header("location", "https://example.com")
          |> send_resp(302, "redirecting to https://example.com")
        else
          conn
          |> put_resp_header("content-type", "text/html")
          |> send_resp(200, @normal_body)
        end
      end)

      stub_installation()

      result = run_checks()
      assert_receive :redirect_sent
      assert_receive :redirect_sent
      refute_receive _

      rating = Checks.interpret_diagnostics(result)
      assert rating.ok?
      assert rating.errors == []
      assert rating.recommendations == []
    end

    test "fetching will not follow more than 2 redirect" do
      test = self()

      stub_fetch_body(fn conn ->
        send(test, :redirect_sent)

        conn
        |> put_resp_header("location", "https://example.com")
        |> send_resp(302, "redirecting to https://example.com")
      end)

      stub_installation()

      result = run_checks()

      assert_receive :redirect_sent
      assert_receive :redirect_sent
      assert_receive :redirect_sent
      refute_receive _

      rating = Checks.interpret_diagnostics(result)
      refute rating.ok?
      assert rating.errors == ["We couldn't reach https://example.com. Is your site up?"]

      assert rating.recommendations == [
               {"If your site is running at a different location, please manually check your integration",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end

    test "fetching body fails at non-2xx status, but installation is ok" do
      stub_fetch_body(599, "boo")
      stub_installation()

      result = run_checks()

      rating = Checks.interpret_diagnostics(result)
      refute rating.ok?
      assert rating.errors == ["We couldn't reach https://example.com. Is your site up?"]

      assert rating.recommendations == [
               {"If your site is running at a different location, please manually check your integration",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end

    @snippet_in_body """
    <html>
    <head>
    </head>
    <body>
    Hello
    <script defer data-domain="example.com" src="http://localhost:8000/js/script.js"></script>
    </body>
    </html>
    """

    test "detecting snippet in body" do
      stub_fetch_body(200, @snippet_in_body)
      stub_installation()

      result = run_checks()
      rating = Checks.interpret_diagnostics(result)

      refute rating.ok?
      assert rating.errors == ["Plausible snippet is placed in the body of your site"]

      assert rating.recommendations == [
               {"Please relocate the snippet to the header of your site",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end

    @many_snippets """
    <html>
    <head>
    <script defer data-domain="example.com" src="https://plausible.io/js/script.js"></script>
    <script defer data-domain="example.com" src="https://plausible.io/js/script.js"></script>
    </head>
    <body>
    Hello
    <script defer data-domain="example.com" src="https://plausible.io/js/script.js"></script>
    <script defer data-domain="example.com" src="https://plausible.io/js/script.js"></script>
    <!-- maybe proxy? -->
    <script defer data-domain="example.com" src="https://example.com/js/script.js"></script>
    </body>
    </html>
    """

    test "detecting many snippets" do
      stub_fetch_body(200, @many_snippets)
      stub_installation()

      result = run_checks()
      rating = Checks.interpret_diagnostics(result)

      refute rating.ok?
      assert rating.errors == ["We've found multiple Plausible snippets on your site."]

      assert rating.recommendations == [
               {"Please ensure that only one snippet is used",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end

    @body_no_snippet """
    <html>
    <head>
    </head>
    <body>
    Hello
    </body>
    </html>
    """

    test "detecting snippet after busting cache" do
      stub_fetch_body(fn conn ->
        conn = fetch_query_params(conn)

        if conn.query_params["plausible_verification"] do
          conn
          |> put_resp_content_type("text/html")
          |> send_resp(200, @normal_body)
        else
          conn
          |> put_resp_content_type("text/html")
          |> send_resp(200, @body_no_snippet)
        end
      end)

      stub_installation(fn conn ->
        {:ok, body, _} = read_body(conn)

        if String.contains?(body, "?plausible_verification") do
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Jason.encode!(plausible_installed()))
        else
          raise "Should not get here even"
        end
      end)

      result = run_checks()

      rating = Checks.interpret_diagnostics(result)
      refute rating.ok?
      assert rating.errors == ["We encountered an issue with your site cache"]

      assert rating.recommendations == [
               {"Please clear your cache (or wait for your provider to clear it) to ensure that the latest version of your site is being displayed to all your visitors",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end

    test "detecting no snippet" do
      stub_fetch_body(200, @body_no_snippet)
      stub_installation(200, plausible_installed(false))

      result = run_checks()
      rating = Checks.interpret_diagnostics(result)

      refute rating.ok?
      assert rating.errors == ["We couldn't find the Plausible snippet on your site"]

      assert rating.recommendations == [
               {"Please insert the snippet into your site",
                "https://plausible.io/docs/plausible-script"}
             ]
    end

    test "a check that raises" do
      defmodule FaultyCheckRaise do
        use Plausible.Verification.Check

        @impl true
        def friendly_name, do: "Faulty check"

        @impl true
        def perform(_), do: raise("boom")
      end

      {result, log} =
        with_log(fn ->
          run_checks(checks: [FaultyCheckRaise])
        end)

      assert log =~
               ~s|Error running check Plausible.Verification.DiagnosticsTest.FaultyCheckRaise on https://example.com: %RuntimeError{message: "boom"}|

      rating = Checks.interpret_diagnostics(result)

      refute rating.ok?
      assert rating.errors == ["We couldn't reach https://example.com. Is your site up?"]

      assert rating.recommendations == [
               {"If your site is running at a different location, please manually check your integration",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end

    test "a check that throws" do
      defmodule FaultyCheckThrow do
        use Plausible.Verification.Check

        @impl true
        def friendly_name, do: "Faulty check"

        @impl true
        def perform(_), do: :erlang.throw(:boom)
      end

      {result, log} =
        with_log(fn ->
          run_checks(checks: [FaultyCheckThrow])
        end)

      assert log =~
               ~s|Error running check Plausible.Verification.DiagnosticsTest.FaultyCheckThrow on https://example.com: :boom|

      rating = Checks.interpret_diagnostics(result)
      refute rating.ok?
      assert rating.errors == ["We couldn't reach https://example.com. Is your site up?"]

      assert rating.recommendations == [
               {"If your site is running at a different location, please manually check your integration",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end

    test "disallowed via content-security-policy" do
      stub_fetch_body(fn conn ->
        conn
        |> put_resp_header("content-security-policy", "default-src 'self' foo.local")
        |> put_resp_content_type("text/html")
        |> send_resp(200, @normal_body)
      end)

      stub_installation(200, plausible_installed(false))

      result = run_checks()
      rating = Checks.interpret_diagnostics(result)

      refute rating.ok?

      assert rating.errors == ["We encountered an issue with your site's CSP"]

      assert rating.recommendations == [
               {
                 "Please add plausible.io domain specifically to the allowed list of domains in your Content Security Policy (CSP)",
                 "https://plausible.io/docs/troubleshoot-integration"
               }
             ]
    end

    test "disallowed via content-security-policy with no snippet should make the latter a priority" do
      stub_fetch_body(fn conn ->
        conn
        |> put_resp_header("content-security-policy", "default-src 'self' foo.local")
        |> put_resp_content_type("text/html")
        |> send_resp(200, @body_no_snippet)
      end)

      stub_installation(200, plausible_installed(false))

      result = run_checks()
      rating = Checks.interpret_diagnostics(result)

      refute rating.ok?

      assert rating.errors == ["We couldn't find the Plausible snippet on your site"]
    end

    test "allowed via content-security-policy" do
      stub_fetch_body(fn conn ->
        conn
        |> put_resp_header(
          "content-security-policy",
          Enum.random([
            "default-src 'self'; script-src plausible.io; connect-src #{PlausibleWeb.Endpoint.host()}",
            "default-src 'self' *.#{PlausibleWeb.Endpoint.host()}"
          ])
        )
        |> put_resp_content_type("text/html")
        |> send_resp(200, @normal_body)
      end)

      stub_installation()
      result = run_checks()

      rating = Checks.interpret_diagnostics(result)

      assert rating.ok?
      assert rating.errors == []
      assert rating.recommendations == []
    end

    test "running checks sends progress messages" do
      stub_fetch_body(200, @normal_body)
      stub_installation()

      final_state = run_checks(report_to: self())

      assert_receive {:verification_check_start, {Checks.FetchBody, %State{}}}
      assert_receive {:verification_check_start, {Checks.CSP, %State{}}}
      assert_receive {:verification_check_start, {Checks.ScanBody, %State{}}}
      assert_receive {:verification_check_start, {Checks.Snippet, %State{}}}
      assert_receive {:verification_check_start, {Checks.SnippetCacheBust, %State{}}}
      assert_receive {:verification_check_start, {Checks.Installation, %State{}}}
      assert_receive {:verification_end, %State{} = ^final_state}
      refute_receive _
    end

    @gtm_body """
    <html>
    <head>
    </head>
    <body>
    Hello
     <noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-XXXX" height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
    </body>
    </html>
    """

    test "detecting gtm" do
      stub_fetch_body(200, @gtm_body)
      stub_installation(200, plausible_installed(false))

      result = run_checks()
      rating = Checks.interpret_diagnostics(result)

      refute rating.ok?
      assert rating.errors == ["We encountered an issue with your Plausible integration"]

      assert rating.recommendations == [
               {"As you're using Google Tag Manager, you'll need to use a GTM-specific Plausible snippet",
                "https://plausible.io/docs/google-tag-manager"}
             ]
    end

    test "non-html body" do
      stub_fetch_body(fn conn ->
        conn
        |> put_resp_content_type("image/png")
        |> send_resp(200, :binary.copy(<<0>>, 100))
      end)

      stub_installation(200, plausible_installed(false))

      result = run_checks()

      rating = Checks.interpret_diagnostics(result)
      refute rating.ok?
      assert rating.errors == ["We couldn't reach https://example.com. Is your site up?"]

      assert rating.recommendations == [
               {"If your site is running at a different location, please manually check your integration",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end

    @proxied_script_body """
    <html>
    <head>
    <script defer data-domain="example.com" src="https://proxy.example.com/js/script.js"></script>
    </head>
    <body>Hello</body>
    </html>
    """

    test "proxied setup working OK" do
      stub_fetch_body(200, @proxied_script_body)
      stub_installation()

      result = run_checks()

      rating = Checks.interpret_diagnostics(result)
      assert rating.ok?
      assert rating.errors == []
      assert rating.recommendations == []
    end

    test "proxied setup, function defined but callback won't fire" do
      stub_fetch_body(200, @proxied_script_body)
      stub_installation(200, plausible_installed(true, 0))

      result = run_checks()
      rating = Checks.interpret_diagnostics(result)

      refute rating.ok?
      assert rating.errors == ["We encountered an error with your Plausible proxy"]

      assert rating.recommendations == [
               {"Please check whether you've configured the /event route correctly",
                "https://plausible.io/docs/proxy/introduction"}
             ]
    end

    test "proxied setup, function undefined, callback won't fire" do
      stub_fetch_body(200, @proxied_script_body)
      stub_installation(200, plausible_installed(false, 0))

      result = run_checks()
      rating = Checks.interpret_diagnostics(result)

      refute rating.ok?
      assert rating.errors == ["We encountered an error with your Plausible proxy"]

      assert rating.recommendations ==
               [
                 {"Please check your proxy configuration to make sure it's set up correctly",
                  "https://plausible.io/docs/proxy/introduction"}
               ]
    end

    test "non-proxied setup, but callback fails to fire" do
      stub_fetch_body(200, @normal_body)
      stub_installation(200, plausible_installed(true, 0))

      result = run_checks()

      rating = Checks.interpret_diagnostics(result)
      refute rating.ok?
      assert ["Your Plausible integration is not working"]

      assert rating.recommendations == [
               {"Please manually check your integration to make sure that the Plausible snippet has been inserted correctly",
                "https://plausible.io/docs/troubleshoot-integration"}
             ]
    end
  end

  defp run_checks(extra_opts \\ []) do
    Checks.run(
      "https://example.com",
      "example.com",
      Keyword.merge([async?: false, report_to: nil, slowdown: 0], extra_opts)
    )
  end

  defp stub_fetch_body(f) when is_function(f, 1) do
    Req.Test.stub(Plausible.Verification.Checks.FetchBody, f)
  end

  defp stub_installation(f) when is_function(f, 1) do
    Req.Test.stub(Plausible.Verification.Checks.Installation, f)
  end

  defp stub_fetch_body(status, body) do
    stub_fetch_body(fn conn ->
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(status, body)
    end)
  end

  defp stub_installation(status \\ 200, json \\ plausible_installed()) do
    stub_installation(fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(json))
    end)
  end

  defp plausible_installed(bool \\ true, callback_status \\ 202) do
    %{"data" => %{"plausibleInstalled" => bool, "callbackStatus" => callback_status}}
  end
end
