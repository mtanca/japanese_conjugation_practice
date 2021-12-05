defmodule JapaneseVerbConjugation.Repo.Migrations.CreateCardDecks do
  use Ecto.Migration

  def change do
    create table(:card_decks) do
      add :card_id, :integer
      add :deck_id, :integer

      timestamps()
    end
  end
end
