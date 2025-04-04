defmodule Toolscout.Repo.Migrations.AddHashValueToBatches do
  use Ecto.Migration

  def change do
    alter table(:tool_batches) do
      add :hash_value, :string
    end
  end
end
