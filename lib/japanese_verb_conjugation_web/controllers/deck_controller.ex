defmodule JapaneseVerbConjugationWeb.DeckController do
  use JapaneseVerbConjugationWeb, :controller

  def index(conn, _params) do
    decks = JapaneseVerbConjugation.Decks.list_decks()

    data =
      Enum.map(decks, fn deck ->
        %{
          deck: deck,
          card_count: Enum.count(JapaneseVerbConjugation.Decks.list_cards(deck.id)),
          last_used: deck.last_used
        }
      end)

    json(conn, %{"data" => data})
  end
end
