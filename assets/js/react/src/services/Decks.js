import { APIHelper } from "./api";

class Deck {
  JSON_HEADERS = {
    Accept: "application/json",
    "Content-Type": "application/json"
  };

  fetchAll() {
    const req = {
      headers: this.JSON_HEADERS,
      method: "GET"
    };

    return APIHelper.callAPI(`/decks`, req);
  }
}

export const DeckService = new Deck();
