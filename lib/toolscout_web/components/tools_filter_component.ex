defmodule ToolscoutWeb.ToolsFilterComponent do
  use ToolscoutWeb, :html


  attr :search,   :string, default: ""
  attr :sort_dir, :atom,   default: :asc
  attr :by_batch, :string, default: ""
  attr :batches,  :list,   required: true

  def tools_filter(assigns) do
    ~H"""
    <div class="bg-white p-4 rounded-lg shadow space-y-4">
      <!-- search -->
      <form phx-change="search">
        <input
          type="text"
          name="search"
          value={@search}
          placeholder="Search…"
          class="w-full px-3 py-2 border border-gray-300 rounded focus:ring focus:ring-blue-300"
        />
      </form>

      <!-- sort toggle -->
      <button
        phx-click="toggle_sort"
        class="w-full px-3 py-2 border border-gray-300 rounded bg-gray-50 hover:bg-gray-100 text-left"
      >
        Price <span class="float-right"><%= if @sort_dir == :asc, do: "▲", else: "▼" %></span>
      </button>

      <!-- batch selector -->
      <form phx-change="by_batch">
        <select
          name="by_batch"
          class="w-full px-3 py-2 border border-gray-300 rounded focus:ring focus:ring-blue-300"
        >
          <option value="" selected={@by_batch == ""}>All Batches</option>
          <%= for batch <- @batches do %>
            <option value={batch} selected={@by_batch == batch}><%= batch %></option>
          <% end %>
        </select>
      </form>
    </div>
    """
  end
end
