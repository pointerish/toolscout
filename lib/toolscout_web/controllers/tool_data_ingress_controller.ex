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
        Task.start(fn ->
          Gpt.process_prompt(raw_tool_data)
        end)
        json(conn, %{
          message: "Tool batch processing scheduled."
        })
    end
  end
end
