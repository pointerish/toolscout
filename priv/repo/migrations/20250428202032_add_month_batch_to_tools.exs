defmodule Toolscout.Repo.Migrations.AddMonthBatchToTools do
  use Ecto.Migration

  def change do
    alter table(:tools) do
      add :batch_name, :string, default: "April 2025", null: false
    end
  end
end
