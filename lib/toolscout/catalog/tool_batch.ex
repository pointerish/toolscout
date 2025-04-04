defmodule Toolscout.Catalog.ToolBatch do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tool_batches" do
    field :hash_value, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tool_batch, attrs) do
    tool_batch
    |> cast(attrs, [:hash_value])
    |> validate_required([:hash_value])
  end
end
