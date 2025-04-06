defmodule ToolscoutWeb.ToolsListLive do
  use ToolscoutWeb, :live_view

  alias Toolscout.Catalog

  def mount(_params, _session, socket) do
    tools = Catalog.list_tools()
    socket =
      socket
      |> assign(tools: tools, search: "")
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

  def render(assigns) do
    ~H"""
    <div class="w-[75%] mx-auto m-12">

      <h2 class="text-2xl font-bold text-gray-800 mb-2">Tool Catalog</h2>

      <form phx-change="search" class="flex items-center gap-2">
        <input
          type="text"
          name="search"
          value={@search}
          placeholder="Search by name or description..."
          class="w-full px-4 py-2 border border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring focus:ring-blue-200"
        />
      </form>
      <.table id="tools" rows={@tools}>
        <:col :let={tool} label="Name">{tool.name}</:col>
        <:col :let={tool} label="Description">
          <div>
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
        <:col :let={tool} label="Price">${tool.price}</:col>
        <:col :let={tool} label="Tool Photo">
          <.link
            phx-click={ToolscoutWeb.CoreComponents.show_modal(%JS{}, "modal-#{tool.id}")}
            class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Picture <.icon name="hero-eye"/>
          </.link>
          <.modal id={"modal-#{tool.id}"} title={"#{tool.name} | $#{tool.price}"}>
            <img src={tool.image_link} alt={"Image for #{tool.name}"} class="max-w-full" />
          </.modal>
        </:col>
        <:col label="Actions">
          <.link
            navigate={"mailto:leach@supertool.com"} target="_blank"
            class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Email <.icon name="hero-envelope"/>
          </.link>
        </:col>
      </.table>
    </div>
    """
  end

end
