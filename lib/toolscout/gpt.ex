defmodule Toolscout.Gpt do
  alias Toolscout.Catalog

  @api_url System.get_env("GPT_API_URL")
  @api_key System.get_env("GPT_API_KEY")
  @gpt_timeout String.to_integer(System.get_env("GPT_TIMEOUT"))
  @gpt_model System.get_env("GPT_MODEL")
  @base_prompt """
  Extract the tools from the following text and convert them to an array of JSON objects
  with the fields name, price, description and image_link. Return only the JSON as plain text with no markdown,
  as your response will be parsed by another program as JSON.
  STANLEY
  *******

  ST1  #271 miniature router; US made, in the original box, with
       instructions, it can be honed and used as is; bottom right:
          https://www.supertool.com/forsale/mar/t4.jpg             $65.00
  ST2  #5 jack plane; ca.1950 production, used a few times and put
       back in the original box; some no-harm tarnish from sitting,
       some paper tape on the cover, it's a fine worker for those
       starting the endless journey to handtool nirvana; top:
          https://www.supertool.com/forsale/mar/t11.jpg           $110.00
  ST3  #4 smoothing plane; ca.1945 production, used once and put
       back in the original box; with instructional pamphlet, it
       compliments well the previous plane; bottom:
          https://www.supertool.com/forsale/mar/t11.jpg           $115.00
  ST4  #100 Jennings auger set in the original three section wood
       box; super clean, five still in their original wrappers,
       they are the best pattern for boring hardwoods as the lead
       screw pulls them into the work; 1/4" to 1" diameters in 1/16"
       increments, made in the US; top:
          https://www.supertool.com/forsale/mar/t12.jpg           $190.00
  """

  def process_prompt(prompt) do
    # TODO: Implementing chunking here
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{@api_key}"}
    ]

    body =
      %{
        "model" => @gpt_model,
        "input" => @base_prompt
      }
      |> Jason.encode!()

    case HTTPoison.post(@api_url, body, headers, timeout: @gpt_timeout, recv_timeout: @gpt_timeout) do
      {:ok, response} ->
        gpt_response = get_gpt_response(response)

        case gpt_response do
          :error ->
            {:error, :gpt_error}
          response ->
            Catalog.insert_from_gpt_response(response)
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
