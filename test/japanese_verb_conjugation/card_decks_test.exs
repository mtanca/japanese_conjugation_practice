defmodule JapaneseVerbConjugation.CardDecksTest do
  use JapaneseVerbConjugation.DataCase

  alias JapaneseVerbConjugation.CardDecks

  describe "card_decks" do
    alias JapaneseVerbConjugation.CardDecks.CardDeck

    @valid_attrs %{card_id: 42, deck_id: 42}
    @update_attrs %{card_id: 43, deck_id: 43}
    @invalid_attrs %{card_id: nil, deck_id: nil}

    def card_deck_fixture(attrs \\ %{}) do
      {:ok, card_deck} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CardDecks.create_card_deck()

      card_deck
    end

    test "list_card_decks/0 returns all card_decks" do
      card_deck = card_deck_fixture()
      assert CardDecks.list_card_decks() == [card_deck]
    end

    test "get_card_deck!/1 returns the card_deck with given id" do
      card_deck = card_deck_fixture()
      assert CardDecks.get_card_deck!(card_deck.id) == card_deck
    end

    test "create_card_deck/1 with valid data creates a card_deck" do
      assert {:ok, %CardDeck{} = card_deck} = CardDecks.create_card_deck(@valid_attrs)
      assert card_deck.card_id == 42
      assert card_deck.deck_id == 42
    end

    test "create_card_deck/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CardDecks.create_card_deck(@invalid_attrs)
    end

    test "update_card_deck/2 with valid data updates the card_deck" do
      card_deck = card_deck_fixture()
      assert {:ok, %CardDeck{} = card_deck} = CardDecks.update_card_deck(card_deck, @update_attrs)
      assert card_deck.card_id == 43
      assert card_deck.deck_id == 43
    end

    test "update_card_deck/2 with invalid data returns error changeset" do
      card_deck = card_deck_fixture()
      assert {:error, %Ecto.Changeset{}} = CardDecks.update_card_deck(card_deck, @invalid_attrs)
      assert card_deck == CardDecks.get_card_deck!(card_deck.id)
    end

    test "delete_card_deck/1 deletes the card_deck" do
      card_deck = card_deck_fixture()
      assert {:ok, %CardDeck{}} = CardDecks.delete_card_deck(card_deck)
      assert_raise Ecto.NoResultsError, fn -> CardDecks.get_card_deck!(card_deck.id) end
    end

    test "change_card_deck/1 returns a card_deck changeset" do
      card_deck = card_deck_fixture()
      assert %Ecto.Changeset{} = CardDecks.change_card_deck(card_deck)
    end
  end
end
