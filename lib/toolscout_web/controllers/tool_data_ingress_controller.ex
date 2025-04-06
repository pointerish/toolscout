defmodule ToolscoutWeb.ToolDataIngress do
  use ToolscoutWeb, :controller

  alias Toolscout.ToolDataIngress
  alias Toolscout.Gpt

  def run(conn, params) do
    data = Map.get(params, "data")
    leachy_link =
      ToolDataIngress.extract_leachy_link(data)
      |> String.replace("=3D", "")
    raw_tool_data = ToolDataIngress.extract_leachy_raw_data(leachy_link)

    case raw_tool_data do
      {:error, reason} ->
        json(conn, %{error: "Failed to extract raw data: #{reason}"})
      "" ->
        json(conn, %{error: "Empty raw data"})
      _ ->
        process_tool_data(conn, raw_tool_data)
    end
  end

  defp process_tool_data(conn, raw_tool_data) do
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
