defmodule Toolscout.ToolDataIngress do
  alias Toolscout.Catalog
  @base_url "https://email.cloud.secureclick.net/c/"
  @user_agent {"User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"}

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
    case HTTPoison.get(leachy_url, [@user_agent], follow_redirect: true) do
      {:ok, %HTTPoison.Response{body: body}} ->
        body
        |> Floki.parse_document!()
        |> extract_text()

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def extract_leachy_raw_data(leachy_url, :curl) do
    # Step 1: Follow tracking link to get redirect Location
    {headers, _} =
      System.cmd("curl", [
        "-s",
        "-D", "-",
        "-o", "/dev/null",
        "-A", "Mozilla/5.0",
        "--insecure",
        leachy_url
      ])

    redirect_url =
      case headers
           |> String.split("\r\n")
           |> Enum.find(&String.starts_with?(&1, "Location:")) do
        "Location: " <> location ->
          location = String.trim(location)

          cond do
            String.starts_with?(location, "/") ->
              # Relative redirect — resolve against base domain
              URI.merge("http://www.supertool.com", location) |> to_string()

            String.starts_with?(location, "https://www.supertool.com") ->
              # Replace https with http to avoid TLS issues
              String.replace(location, "https://", "http://")

            true ->
              location
          end

        _ ->
          leachy_url
      end
    dbg(redirect_url)

    # Step 2: Fetch final page content using resolved URL
    {body, _} =
      System.cmd("curl", [
        "-sL",
        "-A", "Mozilla/5.0",
        "--insecure",
        redirect_url
      ])

    body
    |> IO.inspect(label: "Curl Response")
    |> Floki.parse_document!()
    |> extract_text()
  end

  def is_tool_batch_new?(tools_data) do
    hash_value = Catalog.hash_tool_batch(tools_data)
    latest_tool_batch = Catalog.get_latest_tool_batch()

    case latest_tool_batch.hash_value do
      ^hash_value -> false
      _ -> true
    end
  end

  defp extract_text(parsed_html) do
    parsed_html
    |> Floki.find("body")
    |> Floki.text()
    |> String.trim()
  end
end
