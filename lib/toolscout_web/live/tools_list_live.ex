defmodule ToolscoutWeb.ToolsListLive do
  use ToolscoutWeb, :live_view

  alias Toolscout.Catalog

  def mount(_params, _session, socket) do
    tools = Catalog.list_tools()

    socket =
      socket
      |> assign(
        tools: tools,
        search: "",
        sort_dir: :asc
      )

    {:ok, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    tools =
      Catalog.list_tools()
      |> Enum.filter(fn tool ->
        String.contains?(String.downcase(tool.name), String.downcase(search)) or
        String.contains?(String.downcase(tool.description), String.downcase(search))
      end)

    {:noreply, assign(socket, search: search, tools: tools)}
  end

  def handle_event("toggle_sort", _params, socket) do
    new_dir = toggle_dir(socket.assigns.sort_dir)

    tools =
      socket.assigns.tools
      |> Enum.sort_by(& &1.price, sort_fun(new_dir))

    {:noreply, assign(socket, tools: tools, sort_dir: new_dir)}
  end

  defp toggle_dir(:asc), do: :desc
  defp toggle_dir(:desc), do: :asc

  defp sort_fun(:asc), do: &<=/2
  defp sort_fun(:desc), do: &>=/2

  def render(assigns) do
    ~H"""
    <div class="w-[95%] md:w-[75%] mx-auto my-6 md:my-12">

      <h2 class="text-2xl font-bold text-gray-800 mb-4 text-center">Tool Catalog</h2>

      <form phx-change="search" class="flex flex-col md:flex-row gap-3 mb-6 items-stretch md:items-end">
        <input
          type="text"
          name="search"
          value={@search}
          placeholder="Search by name or description..."
          class="flex-1 px-4 py-2 border border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring focus:ring-blue-200"
        />
      </form>
      <div class="flex justify-end mb-2">
        <button
          phx-click="toggle_sort"
          class="text-sm text-blue-600 hover:underline flex items-center gap-1"
        >
          Sort by price <%= if @sort_dir == :asc, do: "▲", else: "▼" %>
        </button>
      </div>

      <div>
        <.table id="tools" rows={@tools}>
          <:col :let={tool} label="Name">{tool.name}</:col>

          <:col :let={tool} label="Description">
            <div class="block md:hidden">
              <%= String.slice(tool.description, 0, 30) %>...
            </div>
            <div class="hidden md:block">
              <span><%= String.slice(tool.description, 0, 60) %>...</span>
              <.link
                phx-click={ToolscoutWeb.CoreComponents.show_modal(%JS{}, "desc-modal-#{tool.id}")}
                class="ml-2 text-blue-600 hover:underline text-sm"
              >
                Show more
              </.link>
            </div>
            <.modal id={"desc-modal-#{tool.id}"} title={"#{tool.name}"}>
              <p class="text-gray-800 whitespace-pre-wrap"><%= tool.description %></p>
            </.modal>
          </:col>

          <:col :let={tool} label="Price">
            $<%= tool.price %>
          </:col>

          <:col :let={tool} label="Actions">
            <div class="flex flex-col md:flex-row gap-2 items-start md:items-center">
              <.link
                phx-click={ToolscoutWeb.CoreComponents.show_modal(%JS{}, "modal-#{tool.id}")}
                class="px-4 py-2 text-sm bg-zinc-200 rounded hover:bg-zinc-300 text-center w-full md:w-auto"
              >
                <.icon name="hero-eye" /> View
              </.link>
              <.link
                navigate={"mailto:leach@supertool.com"} target="_blank"
                class="px-4 py-2 text-sm bg-zinc-200 rounded hover:bg-zinc-300 text-center w-full md:w-auto"
              >
                <.icon name="hero-envelope" /> Email
              </.link>
            </div>

            <.modal id={"modal-#{tool.id}"} title={"#{tool.name} | $#{tool.price}"}>
              <img src={tool.image_link} alt={"Image for #{tool.name}"} class="max-w-full" />
            </.modal>
          </:col>
        </.table>
      </div>
    </div>
    """
  end
end
