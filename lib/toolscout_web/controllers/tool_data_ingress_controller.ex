defmodule ToolscoutWeb.ToolDataIngress do
  use ToolscoutWeb, :controller

  alias Toolscout.ToolDataIngress
  alias Toolscout.Gpt

  def run(conn, params) do
    data = Map.get(params, "data")
    leachy_link = ToolDataIngress.extract_leachy_link(data)
    raw_tool_data = ToolDataIngress.extract_leachy_raw_data(leachy_link)

    {new_added_tools_count, _} = Gpt.process_prompt(raw_tool_data)
    json(conn, %{message: "Tools added", count: new_added_tools_count})
  end
end
