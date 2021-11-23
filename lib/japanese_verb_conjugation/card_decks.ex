defmodule JapaneseVerbConjugation.CardDecks do
  @moduledoc """
  The CardDecks context.
  """

  import Ecto.Query, warn: false
  alias JapaneseVerbConjugation.Repo

  alias JapaneseVerbConjugation.CardDecks.CardDeck

  @doc """
  Returns the list of card_decks.

  ## Examples

      iex> list_card_decks()
      [%CardDeck{}, ...]

  """
  def list_card_decks do
    Repo.all(CardDeck)
  end

  @doc """
  Gets a single card_deck.

  Raises `Ecto.NoResultsError` if the Card deck does not exist.

  ## Examples

      iex> get_card_deck!(123)
      %CardDeck{}

      iex> get_card_deck!(456)
      ** (Ecto.NoResultsError)

  """
  def get_card_deck!(id), do: Repo.get!(CardDeck, id)

  @doc """
  Creates a card_deck.

  ## Examples

      iex> create_card_deck(%{field: value})
      {:ok, %CardDeck{}}

      iex> create_card_deck(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_card_deck(attrs \\ %{}) do
    %CardDeck{}
    |> CardDeck.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a card_deck.

  ## Examples

      iex> update_card_deck(card_deck, %{field: new_value})
      {:ok, %CardDeck{}}

      iex> update_card_deck(card_deck, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_card_deck(%CardDeck{} = card_deck, attrs) do
    card_deck
    |> CardDeck.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a card_deck.

  ## Examples

      iex> delete_card_deck(card_deck)
      {:ok, %CardDeck{}}

      iex> delete_card_deck(card_deck)
      {:error, %Ecto.Changeset{}}

  """
  def delete_card_deck(%CardDeck{} = card_deck) do
    Repo.delete(card_deck)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking card_deck changes.

  ## Examples

      iex> change_card_deck(card_deck)
      %Ecto.Changeset{data: %CardDeck{}}

  """
  def change_card_deck(%CardDeck{} = card_deck, attrs \\ %{}) do
    CardDeck.changeset(card_deck, attrs)
  end
end
