defmodule JapaneseVerbConjugation.Repo.Migrations.CreateVerbs do
  use Ecto.Migration

  def change do
    create table(:verbs) do
      add :plain_base, :string
      add :class, :string
      add :romaji, :string
      add :meaning, :string

      timestamps()
    end

    create unique_index(:verbs, [:plain_base])
  end
end
