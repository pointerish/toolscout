defmodule Toolscout.ToolDataIngress do
  @base_url "https://email.cloud.secureclick.net/c/"

  def extract_leachy_link(raw_data) do
    parts = String.split(raw_data, @base_url, parts: 2)

    case parts do
      [_, after_sep] ->
        [url, _] = String.split(after_sep, ")", parts: 2)
        String.trim("#{@base_url}#{url}")
      _ ->
        {:error, :no_link_found}
    end
  end

  def extract_leachy_raw_data(leachy_url) do
    case HTTPoison.get(leachy_url, [], [follow_redirect: true]) do
      {:ok, %HTTPoison.Response{body: body}}->
        body
        |> Floki.parse_document!()
        |> extract_text()
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

  defp extract_text(parsed_html) do
    parsed_html
    |> Floki.find("body")  # You can adjust the selector as needed
    |> Floki.text()        # Extracts all text content inside the body
    |> String.trim()       # Removes leading/trailing whitespace
  end
end
