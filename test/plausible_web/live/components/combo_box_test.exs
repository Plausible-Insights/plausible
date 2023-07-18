defmodule PlausibleWeb.Live.Components.ComboBoxTest do
  use PlausibleWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Plausible.Test.Support.HTML

  alias PlausibleWeb.Live.Components.ComboBox

  @ul "ul#dropdown-test-component[x-show=isOpen][x-ref=suggestions]"

  describe "static rendering" do
    test "renders suggestions" do
      assert doc = render_sample_component(new_options(10))

      assert element_exists?(
               doc,
               ~s/input#test-component[name="display-test-component"][phx-change="search"]/
             )

      assert element_exists?(doc, @ul)

      for i <- 1..10 do
        assert element_exists?(doc, suggestion_li(i))
      end
    end

    test "renders up to 15 suggestions by default" do
      assert doc = render_sample_component(new_options(20))

      assert element_exists?(doc, suggestion_li(14))
      assert element_exists?(doc, suggestion_li(15))

      refute element_exists?(doc, suggestion_li(16))
      refute element_exists?(doc, suggestion_li(17))

      assert Floki.text(doc) =~ "Max results reached"
    end

    test "Alpine.js: renders attrs focusing suggestion elements" do
      assert doc = render_sample_component(new_options(10))
      li1 = doc |> find(suggestion_li(1)) |> List.first()
      li2 = doc |> find(suggestion_li(2)) |> List.first()

      assert text_of_attr(li1, "@mouseenter") == "setFocus(0)"
      assert text_of_attr(li2, "@mouseenter") == "setFocus(1)"

      assert text_of_attr(li1, "x-bind:class") =~ "focus === 0"
      assert text_of_attr(li2, "x-bind:class") =~ "focus === 1"
    end

    test "Alpine.js: component refers to window.suggestionsDropdown" do
      assert new_options(2)
             |> render_sample_component()
             |> find("div#input-picker-main-test-component")
             |> text_of_attr("x-data") =~ "window.suggestionsDropdown('test-component')"
    end

    test "Alpine.js: component sets up keyboard navigation" do
      main =
        new_options(2)
        |> render_sample_component()
        |> find("div#input-picker-main-test-component")

      assert text_of_attr(main, "x-on:keydown.arrow-up") == "focusPrev"
      assert text_of_attr(main, "x-on:keydown.arrow-down") == "focusNext"
      assert text_of_attr(main, "x-on:keydown.enter") == "select()"
    end

    test "Alpine.js: component sets up close on click-away" do
      assert new_options(2)
             |> render_sample_component()
             |> find("div#input-picker-main-test-component div div")
             |> text_of_attr("@click.away") == "close"
    end

    test "Alpine.js: component sets up open on focusing the display input" do
      assert new_options(2)
             |> render_sample_component()
             |> find("input#test-component")
             |> text_of_attr("x-on:focus") == "open"
    end

    test "Alpine.js: dropdown is annotated and shows when isOpen is true" do
      dropdown =
        new_options(2)
        |> render_sample_component()
        |> find("#dropdown-test-component")

      assert text_of_attr(dropdown, "x-show") == "isOpen"
      assert text_of_attr(dropdown, "x-ref") == "suggestions"
    end

    test "Dropdown shows a notice when no suggestions exist" do
      doc = render_sample_component([])

      assert text_of_element(doc, "#dropdown-test-component") ==
               "No matches found. Try searching for something different."
    end
  end

  describe "integration - live rendering" do
    setup [:create_user, :log_in, :create_site]

    test "search reacts to the input, the user types in", %{conn: conn, site: site} do
      setup_goals(site, ["Hello World", "Plausible", "Another World"])
      lv = get_liveview(conn, site)

      doc = type_into_combo(lv, 1, "hello")

      assert text_of_element(doc, "#dropdown-step-1-option-0") == "Hello World"

      doc = type_into_combo(lv, 1, "plausible")

      assert text_of_element(doc, "#dropdown-step-1-option-0") == "Plausible"
    end

    test "selecting an option prefills input values", %{conn: conn, site: site} do
      {:ok, [_, _, g3]} = setup_goals(site, ["Hello World", "Plausible", "Another World"])
      lv = get_liveview(conn, site)

      doc = type_into_combo(lv, 1, "another")

      refute element_exists?(doc, ~s/input[type="hidden"][value="#{g3.id}"]/)
      refute element_exists?(doc, ~s/input[type="text"][value="Another World"]/)

      lv
      |> element("li#dropdown-step-1-option-0 a")
      |> render_click()

      assert lv
             |> element("#submit-step-1")
             |> render()
             |> element_exists?(~s/input[type="hidden"][value="#{g3.id}"]/)

      assert lv
             |> element("#step-1")
             |> render()
             |> element_exists?(~s/input[type="text"][value="Another World"]/)
    end

    test "selecting one option reduces suggestions in the other", %{conn: conn, site: site} do
      setup_goals(site, ["Hello World", "Plausible", "Another World"])
      lv = get_liveview(conn, site)

      type_into_combo(lv, 1, "another")

      lv
      |> element("li#dropdown-step-1-option-0 a")
      |> render_click()

      doc = type_into_combo(lv, 2, "another")

      refute text_of_element(doc, "ul#dropdown-step-1 li") =~ "Another World"

      assert text_of_element(doc, "ul#dropdown-step-2 li") =~ "Hello World"
      assert text_of_element(doc, "ul#dropdown-step-2 li") =~ "Plausible"
      refute text_of_element(doc, "ul#dropdown-step-2 li") =~ "Another World"
    end

    test "removing one option alters suggestions for other", %{conn: conn, site: site} do
      setup_goals(site, ["Hello World", "Plausible", "Another World"])

      lv = get_liveview(conn, site)

      lv |> element(~s/a[phx-click="add-step"]/) |> render_click()

      type_into_combo(lv, 2, "hello")

      lv
      |> element("li#dropdown-step-2-option-0 a")
      |> render_click()

      doc = type_into_combo(lv, 1, "hello")

      refute text_of_element(doc, "ul#dropdown-step-1 li") =~ "Hello World"

      lv |> element(~s/#remove-step-2/) |> render_click()

      doc = type_into_combo(lv, 1, "hello")

      assert text_of_element(doc, "ul#dropdown-step-1 li") =~ "Hello World"
    end
  end

  defp render_sample_component(options) do
    render_component(ComboBox,
      options: options,
      submit_name: "test-submit-name",
      id: "test-component",
      suggest_mod: ComboBox.StaticSearch
    )
  end

  defp new_options(n) do
    Enum.map(1..n, &{&1, "TestOption #{&1}"})
  end

  defp get_liveview(conn, site) do
    conn = assign(conn, :live_module, PlausibleWeb.Live.FunnelSettings)
    {:ok, lv, _html} = live(conn, "/#{site.domain}/settings/funnels")
    lv |> element(~s/button[phx-click="add-funnel"]/) |> render_click()
    assert form_view = find_live_child(lv, "funnels-form")
    form_view |> element("form") |> render_change(%{funnel: %{name: "My test funnel"}})
    form_view
  end

  defp setup_goals(site, goal_names) when is_list(goal_names) do
    goals =
      Enum.map(goal_names, fn goal_name ->
        {:ok, g} = Plausible.Goals.create(site, %{"event_name" => goal_name})
        g
      end)

    {:ok, goals}
  end

  defp type_into_combo(lv, idx, text) do
    lv
    |> element("input#step-#{idx}")
    |> render_change(%{
      "_target" => ["display-step-#{idx}"],
      "display-step-#{idx}" => "#{text}"
    })
  end

  defp suggestion_li(idx) do
    ~s/#{@ul} li#dropdown-test-component-option-#{idx - 1}/
  end
end
