defmodule Toolscout.ToolDataIngressTest do
  use ExUnit.Case, async: true
  alias Toolscout.ToolDataIngress

  test "extracts href value from encoded HTML string" do
    raw_data = "https://email.cloud.secureclick.net/c/5627?id=3D508817.908.1.92ae5a125ea611fb8d9b6d93e693aac0 )"

    expected_href = "https://email.cloud.secureclick.net/c/5627?id=3D508817.908.1.92ae5a125ea611fb8d9b6d93e693aac0"

    assert ToolDataIngress.extract_leachy_link(raw_data) == expected_href
  end

  test "returns error when no secureclick.net href is found" do
    raw_data = "<p>No links here</p>"

    assert ToolDataIngress.extract_leachy_link(raw_data) == {:error, :no_link_found}
  end
end
