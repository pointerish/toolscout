defmodule ToolscoutWeb.ToolsTableComponent do
  use ToolscoutWeb, :html

  attr :tools, :list, required: true

  def tools_table(assigns) do
    ~H"""
    <!-- Desktop Table View -->
    <div class="hidden md:block">
      <.table id="tools" rows={@tools}>
        <:col :let={tool} label="Name">{tool.name}</:col>
        <:col :let={tool} label="Description">
          {String.slice(tool.description, 0, 60)}...
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
              navigate="mailto:leach@supertool.com"
              target="_blank"
              class="px-4 py-2 text-sm bg-zinc-200 rounded hover:bg-zinc-300 text-center w-full md:w-auto"
            >
              <.icon name="hero-envelope" /> Email
            </.link>
          </div>

          <.modal
            id={"modal-#{tool.id}"}
            title={"#{tool.name} | $#{tool.price}"}
            footer={tool.description}
          >
            <img src={tool.image_link} alt={"Image for #{tool.name}"} class="max-w-full" />
          </.modal>
        </:col>
      </.table>
    </div>

    <!-- Mobile Card View -->
    <div class="block md:hidden space-y-4">
      <%= for tool <- @tools do %>
        <div class="p-4 border rounded shadow-sm bg-white">
          <h3 class="text-lg font-semibold text-zinc-800">{tool.name}</h3>
          <p class="text-sm text-zinc-600 mt-1 mb-2">
            {String.slice(tool.description, 0, 60)}...
          </p>
          <p class="text-sm text-zinc-600 mt-1 mb-2">
            <b>${tool.price}</b>
          </p>
          <.link
            phx-click={ToolscoutWeb.CoreComponents.show_modal(%JS{}, "modal-mobile-#{tool.id}")}
            class="inline-block px-4 py-2 text-sm bg-zinc-200 rounded hover:bg-zinc-300"
          >
            View Details
          </.link>

          <.modal id={"modal-mobile-#{tool.id}"} title={tool.name}>
            <img src={tool.image_link} alt={"Image for #{tool.name}"} class="max-w-full mb-4" />
            <p class="text-zinc-700 whitespace-pre-wrap mb-4">{tool.description}</p>
            <p class="font-semibold mb-2">Price: ${tool.price}</p>
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

    <button
        type="button"
        onclick="window.scrollTo({ top: 0, behavior: 'smooth' })"
        class="fixed bottom-4 right-4 p-3 bg-zinc-200 rounded-full hover:bg-zinc-300 shadow-lg z-50"
      >
        <.icon name="hero-arrow-up" />
      </button>
    """
  end
end
