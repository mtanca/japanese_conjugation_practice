import { APIHelper } from "./api";

class Search {
  JSON_HEADERS = {
    Accept: "application/json",
    "Content-Type": "application/json"
  };

  search(params) {
    const req = {
      headers: this.JSON_HEADERS,
      method: "POST",
      body: JSON.stringify(params)
    };

    return APIHelper.callAPI(`/search`, req);
  }

  fetchAll() {
    const req = {
      headers: this.JSON_HEADERS,
      method: "GET"
    };

    return APIHelper.callAPI(`/search/all`, req);
  }
}

export const SearchService = new Search();
