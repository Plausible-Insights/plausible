defmodule PlausibleWeb.Favicon do
  @moduledoc """
    A Plug that fetches favicon images from DuckDuckGo and returns them
    to the Plausible frontend.

    The proxying is there so we can reduce the number of third-party domains that
    the browser clients need to connect to. Our goal is to have 0 third-party domain
    connections on the website for privacy reasons.

    This module also maps between categorized sources and their respective URLs for favicons.
    What does that mean exactly? During ingestion we use `PlausibleWeb.RefInspector.parse/1` to
    categorize our referrer sources like so:

    google.com -> Google
    google.co.uk -> Google
    google.com.au -> Google

    So when we show Google as a source in the dashboard, the request to this plug will come as:
    https://plausible/io/favicon/sources/Google

    Now, when we want to show a favicon for Google, we need to convert Google -> google.com or
    some other hostname owned by Google:
    https://icons.duckduckgo.com/ip3/google.com.ico

    The mapping from source category -> source hostname is stored in "#{@referer_domains_file}" and
    managed by `Mix.Tasks.GenerateReferrerFavicons.run/1`
  """
  @referer_domains_file "priv/referer_favicon_domains.json"
  import Plug.Conn
  alias Plausible.HTTPClient

  def init(_) do
    domains =
      case File.read(Application.app_dir(:plausible, @referer_domains_file)) do
        {:ok, contents} ->
          Jason.decode!(contents)

        _ ->
          %{}
      end

    [favicon_domains: domains]
  end

  @doc """
    Proxies HTTP request to DuckDuckGo favicon service. Swallows hop-by-hop HTTP headers that
    should not be forwarded as defined in RFC 2616 (https://www.rfc-editor.org/rfc/rfc2616#section-13.5.1)
  """
  def call(conn, favicon_domains: favicon_domains) do
    case conn.path_info do
      ["favicon", "sources", source] ->
        clean_source = URI.decode_www_form(source)
        domain = Map.get(favicon_domains, clean_source, clean_source)

        case HTTPClient.impl().get("https://icons.duckduckgo.com/ip3/#{domain}.ico") do
          {:ok, res} ->
            send_response(conn, res)

          _ ->
            send_resp(conn, 503, "") |> halt
        end

      _ ->
        conn
    end
  end

  defp send_response(conn, res) do
    headers = remove_hop_by_hop_headers(res)
    conn = %Plug.Conn{conn | resp_headers: headers}

    send_resp(conn, 200, res.body) |> halt
  end

  @hop_by_hop_headers [
    "connection",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailers",
    "transfer-encoding",
    "upgrade"
  ]
  defp remove_hop_by_hop_headers(%Finch.Response{headers: headers}) do
    Enum.filter(headers, fn {key, _} -> key not in @hop_by_hop_headers end)
  end
end
