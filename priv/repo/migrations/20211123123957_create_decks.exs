defmodule JapaneseVerbConjugation.Repo.Migrations.CreateDecks do
  use Ecto.Migration

  def change do
    create table(:decks) do
      add :name, :string
      add :last_used, :utc_datetime

      timestamps()
    end
  end
end
