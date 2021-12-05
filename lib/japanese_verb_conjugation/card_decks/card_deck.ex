defmodule JapaneseVerbConjugation.CardDecks.CardDeck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "card_decks" do
    field :card_id, :integer
    field :deck_id, :integer

    timestamps()
  end

  @doc false
  def changeset(card_deck, attrs) do
    card_deck
    |> cast(attrs, [:card_id, :deck_id])
    |> validate_required([:card_id, :deck_id])
  end
end
