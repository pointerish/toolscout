defmodule Toolscout.Repo.Migrations.CreateToolBatches do
  use Ecto.Migration

  def change do
    create table(:tool_batches) do

      timestamps(type: :utc_datetime)
    end
  end
end
