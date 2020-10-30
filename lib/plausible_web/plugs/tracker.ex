defmodule PlausibleWeb.Tracker do
  import Plug.Conn
  @templates [
    "plausible.js",
    "plausible.hash.js",
    "plausible.hash.outbound-links.js",
    "plausible.outbound-links.js",
    "p.js"
  ]
  @aliases %{
    "plausuble.js" => ["analytics.js"],
    "plausible.hash.outbound-links.js" => ["plausible.outbound-links.hash.js"]
  }

  #  1 hour
  @max_age 3600

  def init(_) do
    templates = Enum.reduce(@templates, %{}, fn template_filename, rendered_templates ->
      rendered = EEx.eval_file("priv/tracker/js/" <> template_filename, base_url: PlausibleWeb.Endpoint.url())
      aliases = Map.get(@aliases, template_filename, [])
      filenames = [template_filename] ++ aliases
      Enum.map(filenames, fn filename -> {"/js/" <> filename, rendered} end)
      |> Enum.into(%{})
      |> Map.merge(rendered_templates)
    end)

    [templates: templates]
  end

  def call(conn, templates: templates) do
    case templates[conn.request_path] do
      found when is_binary(found) -> send_js(conn, found)
      nil -> conn
    end
  end

  defp send_js(conn, file) do
    conn
    |> put_resp_header("cache-control", "max-age=#{@max_age},public")
    |> put_resp_header("content-type", "application/javascript")
    |> send_resp(200, file)
  end
end
