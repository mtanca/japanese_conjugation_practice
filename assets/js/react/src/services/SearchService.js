import { APIHelper } from "./api";

class Search {
  JSON_HEADERS = {
    Accept: "application/json",
    "Content-Type": "application/json"
  };

  search(params) {
    const req = {
      headers: this.JSON_HEADERS,
      credentials: "include",
      method: "POST",
      body: JSON.stringify(params)
    };

    return APIHelper.callAPI(`/search`, req);
  }
}

export const SearchService = new Search();
