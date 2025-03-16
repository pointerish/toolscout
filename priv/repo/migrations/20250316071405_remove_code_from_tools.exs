defmodule Toolscout.Repo.Migrations.RemoveCodeFromTools do
  use Ecto.Migration

  def change do
    alter table(:tools) do
      remove :code
    end
  end
end
