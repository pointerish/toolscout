defmodule Toolscout.Repo.Migrations.AddUniqueConstraintToHashValue do
  use Ecto.Migration

  def change do
    alter table(:tool_batches) do
      modify :hash_value, :string, null: false
    end
    create unique_index(:tool_batches, [:hash_value], name: :unique_hash_value_index)
  end
end
