defmodule PlausibleWeb.Components.Generic do
  @moduledoc """
  Generic reusable components
  """
  use Phoenix.Component, global_prefixes: ~w(x-)

  @notice_themes %{
    yellow: %{
      bg: "bg-yellow-50 dark:bg-yellow-100",
      icon: "text-yellow-400",
      title_text: "text-yellow-800 dark:text-yellow-900",
      body_text: "text-yellow-700 dark:text-yellow-800"
    },
    red: %{
      bg: "bg-red-100",
      icon: "text-red-700",
      title_text: "text-red-800 dark:text-red-900",
      body_text: "text-red-700 dark:text-red-800"
    }
  }

  attr(:type, :string, default: "button")
  attr(:class, :string, default: "")
  attr(:disabled, :boolean, default: false)
  attr(:rest, :global)

  slot(:inner_block)

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      disabled={@disabled}
      class={[
        "inline-flex items-center justify-center gap-x-2 rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-700 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:bg-gray-400 dark:disabled:text-white dark:disabled:text-gray-400 dark:disabled:bg-gray-700",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr(:href, :string, required: true)
  attr(:class, :string, default: "")
  attr(:rest, :global)

  slot(:inner_block)

  def button_link(assigns) do
    ~H"""
    <.link
      href={@href}
      class={[
        "inline-flex items-center justify-center gap-x-2 rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-700 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:bg-gray-400 dark:disabled:bg-gray-800",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  attr(:slug, :string, required: true)

  def docs_info(assigns) do
    ~H"""
    <a href={"https://plausible.io/docs/#{@slug}"} rel="noreferrer" target="_blank">
      <Heroicons.information_circle class="text-gray-400 w-6 h-6 absolute top-0 right-0" />
    </a>
    """
  end

  attr(:title, :any, default: nil)
  attr(:size, :atom, default: :sm)
  attr(:theme, :atom, default: :yellow)
  attr(:dismissable_id, :any, default: nil)
  attr(:class, :string, default: "")
  attr(:rest, :global)
  slot(:inner_block)

  def notice(assigns) do
    assigns = assign(assigns, :theme, Map.fetch!(@notice_themes, assigns.theme))

    ~H"""
    <div id={@dismissable_id} class={@dismissable_id && "hidden"}>
      <div class={["rounded-md p-4 relative", @theme.bg, @class]} {@rest}>
        <button
          :if={@dismissable_id}
          class={"absolute right-0 top-0 m-2 #{@theme.title_text}"}
          onclick={"localStorage['notice_dismissed__#{@dismissable_id}'] = 'true'; document.getElementById('#{@dismissable_id}').classList.add('hidden')"}
        >
          <Heroicons.x_mark class="h-4 w-4 hover:stroke-2" />
        </button>
        <div class="flex">
          <div :if={@title} class="flex-shrink-0">
            <svg
              class={"h-5 w-5 #{@theme.icon}"}
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495zM10 5a.75.75 0 01.75.75v3.5a.75.75 0 01-1.5 0v-3.5A.75.75 0 0110 5zm0 9a1 1 0 100-2 1 1 0 000 2z"
                clip-rule="evenodd"
              />
            </svg>
          </div>
          <div class={["w-full", @title && "ml-3"]}>
            <h3 :if={@title} class={"text-#{@size} font-medium #{@theme.title_text} mb-2"}>
              <%= @title %>
            </h3>
            <div class={"text-#{@size} #{@theme.body_text}"}>
              <p>
                <%= render_slot(@inner_block) %>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <script :if={@dismissable_id} data-key={@dismissable_id}>
      const dismissId = document.currentScript.dataset.key
      const localStorageKey = `notice_dismissed__${dismissId}`

      if (localStorage[localStorageKey] !== 'true') {
        document.getElementById(dismissId).classList.remove('hidden')
      }
    </script>
    """
  end

  attr :id, :any, default: nil
  attr :href, :string, required: true
  attr :new_tab, :boolean, default: false
  attr :class, :string, default: ""
  slot :inner_block

  def styled_link(assigns) do
    ~H"""
    <.unstyled_link
      new_tab={@new_tab}
      href={@href}
      class="text-indigo-600 hover:text-indigo-700 dark:text-indigo-500 dark:hover:text-indigo-600"
    >
      <%= render_slot(@inner_block) %>
    </.unstyled_link>
    """
  end

  slot :button, required: true do
    attr :class, :string
  end

  slot :panel, required: true do
    attr :class, :string
  end

  def dropdown(assigns) do
    ~H"""
    <div
      x-data="dropdown"
      x-on:keydown.escape.prevent.stop="close($refs.button)"
      x-on:focusin.window="! $refs.panel.contains($event.target) && close()"
    >
      <button x-ref="button" x-on:click="toggle()" type="button" class={List.first(@button).class}>
        <%= render_slot(List.first(@button)) %>
      </button>
      <div
        x-ref="panel"
        x-show="open"
        x-transition:enter="transition ease-out duration-100"
        x-transition:enter-start="opacity-0 scale-95"
        x-transition:enter-end="opacity-100 scale-100"
        x-transition:leave="transition ease-in duration-75"
        x-transition:leave-start="opacity-100 scale-100"
        x-transition:leave-end="opacity-0 scale-95"
        x-on:click.outside="close($refs.button)"
        style="display: none;"
        class={List.first(@panel).class}
      >
        <%= render_slot(List.first(@panel)) %>
      </div>
    </div>
    """
  end

  attr :href, :string, required: true
  attr :new_tab, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def dropdown_link(assigns) do
    class =
      "w-full inline-flex text-gray-700 dark:text-gray-300 px-3.5 py-1.5 hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-gray-100"

    class =
      if assigns.new_tab do
        "#{class} justify-between"
      else
        class
      end

    assigns = assign(assigns, :class, class)

    ~H"""
    <.unstyled_link new_tab={@new_tab} href={@href} x-on:click="close()" class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </.unstyled_link>
    """
  end

  attr :href, :string, required: true
  attr :new_tab, :boolean, default: false
  attr :class, :string, default: ""
  attr :id, :any, default: nil
  attr :rest, :global
  slot :inner_block

  def unstyled_link(assigns) do
    if assigns[:new_tab] do
      assigns = assign(assigns, :icon_class, icon_class(assigns))

      ~H"""
      <.link
        id={@id}
        class={[
          "inline-flex items-center gap-x-0.5",
          @class
        ]}
        href={@href}
        target="_blank"
        rel="noopener noreferrer"
        {@rest}
      >
        <%= render_slot(@inner_block) %>
        <Heroicons.arrow_top_right_on_square class={["opacity-60", @icon_class]} />
      </.link>
      """
    else
      ~H"""
      <.link class={@class} href={@href} {@rest}>
        <%= render_slot(@inner_block) %>
      </.link>
      """
    end
  end

  attr :class, :any, default: ""

  def spinner(assigns) do
    ~H"""
    <svg
      class={["animate-spin h-4 w-4 text-indigo-500", @class]}
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4">
      </circle>
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      >
      </path>
    </svg>
    """
  end

  defp icon_class(link_assigns) do
    if String.contains?(link_assigns[:class], "text-sm") do
      ["w-3 h-3"]
    else
      ["w-4 h-4"]
    end
  end
end
