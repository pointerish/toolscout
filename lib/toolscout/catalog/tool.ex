defmodule Toolscout.Catalog.Tool do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tools" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :image_link, :string
    belongs_to :tool_batch, Toolscout.Catalog.ToolBatch

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tool, attrs) do
    tool
    |> cast(attrs, [:name, :description, :price, :image_link, :tool_batch_id])
    |> validate_required([:name, :description, :price, :image_link, :tool_batch_id])
  end

end
