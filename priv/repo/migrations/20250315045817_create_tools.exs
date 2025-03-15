defmodule Toolscout.Repo.Migrations.CreateTools do
  use Ecto.Migration

  def change do
    create table(:tools) do
      add :name, :string
      add :code, :string
      add :description, :string
      add :price, :decimal
      add :image_link, :string

      timestamps(type: :utc_datetime)
    end
  end
end
