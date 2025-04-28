defmodule Toolscout.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias Toolscout.Repo

  alias Toolscout.Catalog.Tool
  alias Toolscout.Catalog.ToolBatch

  @doc """
  Returns the list of tools.

  ## Examples

      iex> list_tools()
      [%Tool{}, ...]

  """
  def list_tools do
    Repo.all(Tool)
  end

  @doc """
  Returns the latest tool batch.

  ## Examples

      iex> get_latest_tool_batch()
      [%ToolBatch{}, ...]

  """
  def get_latest_tool_batch do
    query =
      from t in ToolBatch,
        order_by: [desc: t.inserted_at],
        limit: 1

    Repo.one(query)
  end

  @doc """
  Gets a single tool.

  Raises `Ecto.NoResultsError` if the Tool does not exist.

  ## Examples

      iex> get_tool!(123)
      %Tool{}

      iex> get_tool!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tool!(id), do: Repo.get!(Tool, id)

  @doc """
  Creates a tool.

  ## Examples

      iex> create_tool(%{field: value})
      {:ok, %Tool{}}

      iex> create_tool(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tool(attrs \\ %{}) do
    %Tool{}
    |> Tool.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tool.

  ## Examples

      iex> update_tool(tool, %{field: new_value})
      {:ok, %Tool{}}

      iex> update_tool(tool, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tool(%Tool{} = tool, attrs) do
    tool
    |> Tool.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tool.

  ## Examples

      iex> delete_tool(tool)
      {:ok, %Tool{}}

      iex> delete_tool(tool)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tool(%Tool{} = tool) do
    Repo.delete(tool)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tool changes.

  ## Examples

      iex> change_tool(tool)
      %Ecto.Changeset{data: %Tool{}}

  """
  def change_tool(%Tool{} = tool, attrs \\ %{}) do
    Tool.changeset(tool, attrs)
  end

  def list_batches do
    Tool
    |> distinct([t], t.batch_name)
    |> order_by([t], desc: fragment("to_date(?, 'FMMonth YYYY')", t.batch_name))
    |> select([t], t.batch_name)
    |> Repo.all()
  end

  def list_tools_by_batch_name(batch_name) do
    Tool
    |> where([t], t.batch_name == ^batch_name)
    |> Repo.all()
  end

  def hash_tool_batch(tools_data) do
    :crypto.hash(:sha256, tools_data)
    |> Base.encode16(case: :lower)
  end

  def insert_from_gpt_response(tools_data, raw_tool_data) do
    hash_value = hash_tool_batch(raw_tool_data)
    dbg(hash_value)
    tool_batch = Repo.insert!(%ToolBatch{hash_value: hash_value})
    dbg(tool_batch)
    timestamp = DateTime.truncate(DateTime.utc_now(), :second)
    tools_data =
      Enum.map(tools_data, fn tool ->
        Map.new(tool, fn {key, value} ->
          case key do
            "price" -> {String.to_atom(key), Decimal.new(String.replace("#{value}", "$", ""))}
            _ -> {String.to_atom(key), value}
          end
        end)
        |> Map.put(:inserted_at, timestamp)
        |> Map.put(:updated_at, timestamp)
        |> Map.put(:tool_batch_id, tool_batch.id)
        |> Map.put(:batch_name, month_year_str(5))
      end)

    Repo.insert_all(Tool, tools_data)
  end

  def month_year_str(n, date \\ Date.utc_today()) when is_integer(n) and n >= 0 do
    days_in_month = Date.days_in_month(date)

    date_to_format =
      if date.day > days_in_month - n do
        first_of_next_month(date)
      else
        date
      end
    Calendar.strftime(date_to_format, "%B %Y")
  end

  defp first_of_next_month(%Date{year: year, month: 12}) do
    Date.new!(year + 1, 1, 1)
  end
  defp first_of_next_month(%Date{year: year, month: month}) do
    Date.new!(year, month + 1, 1)
  end
end
