defmodule ToolscoutWeb.ToolDataIngress do
  use ToolscoutWeb, :controller

  alias Toolscout.ToolDataIngress
  alias Toolscout.Gpt

  def run(conn, params) do
    data = Map.get(params, "data")
    leachy_link = ToolDataIngress.extract_leachy_link(data)
    dbg(leachy_link)
    raw_tool_data = ToolDataIngress.extract_leachy_raw_data(leachy_link, :curl)
    dbg(raw_tool_data)


    case ToolDataIngress.is_tool_batch_new?(raw_tool_data) do
      true ->
        {new_added_tools_count, _} = Gpt.process_prompt(raw_tool_data)
        json(conn, %{
          message: "Tools added",
          count: new_added_tools_count
        })
      false ->
        json(conn, %{message: "Old tool batch. No new tools added."})
    end
  end
end
