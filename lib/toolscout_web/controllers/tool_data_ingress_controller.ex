defmodule ToolscoutWeb.ToolDataIngress do
  use ToolscoutWeb, :controller

  # alias Toolscout.ToolDataIngress

  def run(conn, params) do
    # Process the request and return a response
    json(conn, %{message: "Data received", data: params})
  end
end
