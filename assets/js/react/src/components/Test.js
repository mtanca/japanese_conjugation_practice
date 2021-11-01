import React, { useState } from "react";
import styled from "styled-components";

import { SearchService } from "../services/SearchService";

const Card = styled.div`
  display: flex;
  flex-direction: column;
  padding: 5pt;
  border: 1pt solid;
  border-radius: 10pt;
  margin-top: 5pt;
  align-items: center;
  justify-content: center;
`;

const CardHirigana = styled.div`
  display: flex;
  flex: 1;
  align-items: center;
`;

const CardDataField = styled.div`
  display: flex;
  flex: 1;
`;

const Test = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [searchResults, setSearchResults] = useState(undefined);

  const handleSearch = () => {
    SearchService.search({ hirigana_verb: searchTerm }).then(res => {
      if (res.success) {
        setSearchResults(res.data);
      }
    });
  };

  const renderInputField = () => {
    return (
      <>
        <label for="site-search">Search the site:</label>
        <input
          type="search"
          id="site-search"
          name="q"
          aria-label="Search"
          onChange={event => setSearchTerm(event.target.value)}
        />
        <button onClick={handleSearch}>Search</button>
      </>
    );
  };

  const renderSearchResults = () => {
    return searchResults.map(verbTense => (
      <Card>
        <CardHirigana>
          <h2>{verbTense.hirigana}</h2>
        </CardHirigana>
        <CardDataField>
          <span>{verbTense.romaji}</span>
        </CardDataField>
        <CardDataField>
          <span>Meaning: </span>　<span>{verbTense.meaning}</span>
        </CardDataField>
        <CardDataField>
          <span>Tense: </span>　<span>{verbTense.tense}</span>
        </CardDataField>
        <CardDataField>
          <span>{verbTense.politness}</span>　<span>{verbTense.form}</span>
        </CardDataField>
      </Card>
    ));
  };

  return (
    <>
      {renderInputField()}
      {searchResults && renderSearchResults()}
    </>
  );
};
export default Test;
