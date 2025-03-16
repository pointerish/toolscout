defmodule Toolscout.Catalog.Tool do
  use Ecto.Schema
  import Ecto.Changeset
  alias Toolscout.Repo

  schema "tools" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :image_link, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tool, attrs) do
    tool
    |> cast(attrs, [:name, :description, :price, :image_link])
    |> validate_required([:name, :description, :price, :image_link])
  end

 
end
