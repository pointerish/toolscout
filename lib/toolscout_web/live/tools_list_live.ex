defmodule ToolscoutWeb.ToolsListLive do
  use ToolscoutWeb, :live_view

  alias Toolscout.Catalog


  def mount(_params, _session, socket) do
    tools = Catalog.list_tools()
    socket = assign(socket, tools: tools)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.table id="tools" rows={@tools}>
      <:col :let={tool} label="Name">{tool.name}</:col>
      <:col :let={tool} label="Description">{tool.description}</:col>
      <:col :let={tool} label="Price">${tool.price}</:col>
      <:col :let={tool} label="Tool Photo">
        <.link
            navigate={tool.image_link} target="_blank"
            class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            See Picture
          </.link>
      </:col>
      <:col :let={tool} label="Actions">
        <.link
            navigate={"mailto:leach@supertool.com"} target="_blank"
            class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Send Email
          </.link>
      </:col>
    </.table>
    """
  end

end
