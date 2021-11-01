defmodule JapaneseVerbConjugation.Repo.Migrations.CreateVerbs do
  use Ecto.Migration

  def change do
    create table(:verbs) do
      add :plain_base, :string
      add :class, :string

      timestamps()
    end
  end
end
