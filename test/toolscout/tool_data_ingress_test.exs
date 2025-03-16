defmodule Toolscout.ToolDataIngressTest do
  use ExUnit.Case, async: true
  alias Toolscout.ToolDataIngress

  test "extracts href value from encoded HTML string" do
    raw_data = """
    <div class=3D"header-container module-1 " style=3D"padding-top: =
    0 !important; padding-right: 0 !important; padding-bottom: 0 !important; pa=
    dding-left: 0 !important;"> <h2 class=3D"" align=3D"left" style=3D"display:=
    block !important; width: 100%; line-height: 1.25; color: #0A0A0A; font-fam=
    ily: &#39;Trebuchet MS&#39;, &#39;Lucida Grande&#39;, &#39;Lucida Sans Unic=
    ode&#39;, &#39;Lucida Sans&#39;, Tahoma, sans-serif; font-size: 20px; text-=
    align: left; direction: ltr; margin-top: 0; margin-right: 0; margin-bottom:=
    0; margin-left: 0; padding-top: 0; padding-right: 0; padding-bottom: 0; pa=
    dding-left: 0;"><span style=3D"display: inline !important; color: #0A0A0A; =
    font-family: &#39;Trebuchet MS&#39;, &#39;Lucida Grande&#39;, &#39;Lucida S=
    ans Unicode&#39;, &#39;Lucida Sans&#39;, Tahoma, sans-serif; font-size: 20p=
    x; text-align: left; direction: ltr; font-weight: normal; margin-top: 0; ma=
    rgin-right: 0; margin-bottom: 0; margin-left: 0; padding-top: 0; padding-ri=
    ght: 0; padding-bottom: 0; padding-left: 0;" dir=3D"ltr"><a target=3D"_blan=
    k" style=3D"text-decoration: none; color: #0260B7;" href=3D"https://email.c
    loud.secureclick.net/c/5627?id=3D508817.908.1.92ae5a125ea611fb8d9b6d93e693a
    ac0">The August 2024 Tool List</a></span></h2><a target=3D"_blan=
    k" style=3D"text-decoration: none; color: #0260B7;" href=3D"https://email.c
    loud.secureclick.net/c/5627?id=3D508817.908.1.92ae5a125ea611fb8d9b6d93e693a
    ac0">The August 2024 Tool List</a>
    """

    expected_href = "https://email.cloud.secureclick.net/c/5627?id=3D508817.908.1.92ae5a125ea611fb8d9b6d93e693aac0"

    assert ToolDataIngress.extract_leachy_link(raw_data) == {:ok, expected_href}
  end

  test "returns error when no secureclick.net href is found" do
    raw_data = "<p>No links here</p>"

    assert ToolDataIngress.extract_leachy_link(raw_data) == {:error, :regex_extraction_failed}
  end
end
