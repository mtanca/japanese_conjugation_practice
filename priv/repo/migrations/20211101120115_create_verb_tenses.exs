defmodule JapaneseVerbConjugation.Repo.Migrations.CreateVerbTenses do
  use Ecto.Migration

  def change do
    create table(:verb_tenses) do
      add :base_verb_id, :integer
      add :tense, :string
      add :form, :string
      add :politness, :string
      add :meaning, :string
      add :romaji, :string
      add :hirigana, :string

      timestamps()
    end
  end
end
