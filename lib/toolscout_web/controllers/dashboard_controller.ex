defmodule ToolscoutWeb.DashboardController do
  use ToolscoutWeb, :controller

  def about(conn, _params) do
    render(conn, :about)
  end
end
