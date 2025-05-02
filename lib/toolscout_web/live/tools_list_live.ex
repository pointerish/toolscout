defmodule ToolscoutWeb.ToolsListLive do
  use ToolscoutWeb, :live_view

  alias Toolscout.Catalog
  import ToolscoutWeb.ToolsFilterComponent, only: [tools_filter: 1]
  import ToolscoutWeb.ToolsTableComponent, only: [tools_table: 1]

  def mount(_params, _session, socket) do
    batches = Catalog.list_batches()
    latest_batch_name = Catalog.get_latest_tool_batch_name()
    tools = fetch_tools("", :asc, "")

    {:ok,
     assign(socket,
       tools: tools,
       search: "",
       sort_dir: :asc,
       by_batch: latest_batch_name,
       batches: batches
     )}
  end

  def handle_event("search", %{"search" => search}, socket) do
    tools = fetch_tools(search, socket.assigns.sort_dir, socket.assigns.by_batch)
    {:noreply, assign(socket, search: search, tools: tools)}
  end

  def handle_event("toggle_sort", _p, socket) do
    new_dir = toggle_dir(socket.assigns.sort_dir)
    tools = fetch_tools(socket.assigns.search, new_dir, socket.assigns.by_batch)
    {:noreply, assign(socket, sort_dir: new_dir, tools: tools)}
  end

  def handle_event("by_batch", %{"by_batch" => by_batch}, socket) do
    tools = fetch_tools(socket.assigns.search, socket.assigns.sort_dir, by_batch)
    {:noreply, assign(socket, by_batch: by_batch, tools: tools)}
  end

  defp fetch_tools(search, sort_dir, "" = _all),
    do: Catalog.list_tools() |> filter_and_sort(search, sort_dir)

  defp fetch_tools(search, sort_dir, batch_name),
    do: Catalog.list_tools_by_batch_name(batch_name) |> filter_and_sort(search, sort_dir)

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
    <div class="w-full mx-auto my-8 px-4">
      <div class="flex flex-col md:flex-row gap-6">
        <!-- on mobile: full-width, margin-bottom; on md+: sidebar & sticky -->
        <aside class="w-full mb-4 md:w-1/4 md:sticky md:top-16 self-start">
          <.tools_filter
            search={@search}
            sort_dir={@sort_dir}
            by_batch={@by_batch}
            batches={@batches}
          />
        </aside>

        <main class="flex-1">
          <!-- wrap your table in an overflow container on small -->
          <div class="overflow-x-auto md:overflow-visible">
            <.tools_table tools={@tools} />
          </div>
        </main>
      </div>
    </div>
    """
  end
end
