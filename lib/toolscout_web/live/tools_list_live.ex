defmodule ToolscoutWeb.ToolsListLive do
  use ToolscoutWeb, :live_view

  alias Toolscout.Catalog

  def mount(_params, _session, socket) do
    tools = Catalog.list_tools()

    {:ok,
     assign(socket,
       tools: tools,
       search: "",
       sort_dir: :asc
     )}
  end

  def handle_event("search", %{"search" => search}, socket) do
    tools =
      Catalog.list_tools()
      |> filter_and_sort(search, socket.assigns.sort_dir)

    {:noreply, assign(socket, search: search, tools: tools)}
  end

  def handle_event("toggle_sort", _params, socket) do
    new_dir = toggle_dir(socket.assigns.sort_dir)

    tools =
      Catalog.list_tools()
      |> filter_and_sort(socket.assigns.search, new_dir)

    {:noreply, assign(socket, tools: tools, sort_dir: new_dir)}
  end

  defp filter_and_sort(tools, search, sort_dir) do
    tools
    |> Enum.filter(fn tool ->
      String.contains?(String.downcase(tool.name), String.downcase(search)) or
        String.contains?(String.downcase(tool.description), String.downcase(search))
    end)
    |> Enum.sort_by(& &1.price, sort_fun(sort_dir))
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

      <!-- Desktop Table View -->
      <div class="hidden md:block">
        <.table id="tools" rows={@tools}>
          <:col :let={tool} label="Name">{tool.name}</:col>
          <:col :let={tool} label="Description">
            <%= String.slice(tool.description, 0, 60) %>...
          </:col>
          <:col :let={tool} label="Price">${tool.price}</:col>
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

            <.modal id={"modal-#{tool.id}"} title={"#{tool.name} | $#{tool.price}"} footer={tool.description}>
              <img src={tool.image_link} alt={"Image for #{tool.name}"} class="max-w-full" />
            </.modal>
          </:col>
        </.table>
      </div>

      <!-- Mobile Card View -->
      <div class="block md:hidden space-y-4">
        <%= for tool <- @tools do %>
          <div class="p-4 border rounded shadow-sm bg-white">
            <h3 class="text-lg font-semibold text-zinc-800"><%= tool.name %></h3>
            <p class="text-sm text-zinc-600 mt-1 mb-2">
              <%= String.slice(tool.description, 0, 60) %>...
            </p>
            <p class="text-sm text-zinc-600 mt-1 mb-2">
              <b>$<%= tool.price %></b>
            </p>
            <.link
              phx-click={ToolscoutWeb.CoreComponents.show_modal(%JS{}, "modal-mobile-#{tool.id}")}
              class="inline-block px-4 py-2 text-sm bg-zinc-200 rounded hover:bg-zinc-300"
            >
              View Details
            </.link>

            <.modal id={"modal-mobile-#{tool.id}"} title={tool.name}>
              <img src={tool.image_link} alt={"Image for #{tool.name}"} class="max-w-full mb-4" />
              <p class="text-zinc-700 whitespace-pre-wrap mb-4"><%= tool.description %></p>
              <p class="font-semibold mb-2">Price: $<%= tool.price %></p>
              <a
                href="mailto:leach@supertool.com"
                class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-500"
              >
                Email About Tool
              </a>
            </.modal>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
