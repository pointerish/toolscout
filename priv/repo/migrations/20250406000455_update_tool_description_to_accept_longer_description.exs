defmodule Toolscout.Repo.Migrations.UpdateToolDescriptionToAcceptLongerDescription do
  use Ecto.Migration

  def change do
    alter table(:tools) do
      modify :description, :string, size: 2048
    end
  end
end
