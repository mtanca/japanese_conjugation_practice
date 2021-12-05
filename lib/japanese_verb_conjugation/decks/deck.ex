defmodule JapaneseVerbConjugation.Decks.Deck do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :last_used]}
  schema "decks" do
    field :name, :string
    field :last_used, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(deck, attrs) do
    deck
    |> cast(attrs, [:name, :last_used])
    |> validate_required([:name])
  end
end
