defmodule Toolscout.Repo.Migrations.AddToolBatchIdToTools do
  use Ecto.Migration

  def change do
    alter table(:tools) do
      add :tool_batch_id, references(:tool_batches, on_delete: :nothing)
    end

    create index(:tools, [:tool_batch_id])
  end
end
