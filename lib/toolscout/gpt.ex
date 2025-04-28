defmodule Toolscout.Gpt do
  alias Toolscout.Catalog

  @gpt_timeout 300_000
  @base_prompt """
  Extract the tools from the following text and convert them to an array of JSON objects
  with the fields name, price, description and image_link. Each tool description has a piece of text
  describing where in the photo the tools is located. It might say something like "Left bottom corner".
  Don't remove that part. Return only the JSON as plain text with no markdown,
  as your response will be parsed by another program as JSON:

  __PROMPT_PLACEHOLDER__
  """

  def process_prompt(prompt) do
    api_url = System.get_env("GPT_API_URL")
    api_key = System.get_env("GPT_API_KEY")
    gpt_model = System.get_env("GPT_MODEL")
    dbg(api_url)
    dbg(api_key)
    dbg(gpt_model)
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]

    body =
      %{
        "model" => gpt_model,
        "input" => String.replace(@base_prompt, "__PROMPT_PLACEHOLDER__", prompt)
      }
      |> Jason.encode!()

    case HTTPoison.post(api_url, body, headers, timeout: @gpt_timeout, recv_timeout: @gpt_timeout) do
      {:ok, response} ->
        gpt_response = get_gpt_response(response)
        dbg(gpt_response)

        case gpt_response do
          :error ->
            {:error, :gpt_error}
          response ->
            dbg(response)
            Catalog.insert_from_gpt_response(response, prompt)
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_gpt_response(%HTTPoison.Response{status_code: 200, body: body}) do
    with decoded <- Jason.decode!(body),
         %{"output" => [%{"content" => [%{"text" => text}]}]} <- decoded do
      Jason.decode!(text)
    else
      _ -> :error
    end
  end
end
