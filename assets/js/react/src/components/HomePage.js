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

const StudySession = styled.div`
  margin-top: 50pt;
  cursor: pointer;
  justify-content: center;
  align-items: center;
  display: flex;
  flex: 1;
  height: 200pt;
  width: 500pt;
  border: 1pt solid;
  border-radius: 10pt;
`;

const HomePage = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [searchResults, setSearchResults] = useState(undefined);

  const [allTenses, setAllTenses] = useState(false);
  const [pastSimple, setPastSimple] = useState(false);
  const [presentSimple, setPresentSimple] = useState(false);
  const [pastContinuous, setPastContinuous] = useState(false);
  const [presentContinuous, setPresentContinuous] = useState(false);

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
      <StudySession>
        <span>VOCAB REVIEW</span>
      </StudySession>
      <StudySession>
        <span>TENSES PRACTICE</span>
        <input
          type="radio"
          id="present_simple"
          name="present_simple"
          checked={presentSimple}
          onClick={e => setPresentSimple(!presentSimple)}
        />
        <label for="present_simple">Present Simple</label>

        <input
          type="radio"
          id="present_continuous"
          name="present_continuous"
          value="present_continuous"
          checked={presentContinuous}
          onClick={e => setPresentSimple(!presentContinuous)}
        />
        <label for="present_continuous">Present Continuous</label>

        <input
          type="radio"
          id="past_simple"
          name="past_simple"
          value="past_simple"
          checked={pastSimple}
          onClick={e => setPastSimple(!pastSimple)}
        />
        <label for="past_simple">Past Simple</label>

        <input
          type="radio"
          id="past_continuous"
          name="past_continuous"
          value="past_continuous"
          checked={pastContinuous}
          onClick={e => setPastContinuous(!pastContinuous)}
        />
        <label for="past_continuous">Past Continuous</label>

        <input type="radio" id="passive" name="passive" value="passive" />
        <label for="passive">Passive</label>

        <input
          type="radio"
          id="all"
          name="all_tenses"
          value="all_tenses"
          checked={allTenses}
          onClick={e => {
            setAllTenses(true);
            setPresentSimple(false);
            setPresentContinuous(false);
            setPastSimple(false);
            setPastContinuous(false);
          }}
        />
        <label for="All Tenses">All Tenses</label>
        <br />
      </StudySession>
      {searchResults && renderSearchResults()}
    </>
  );
};
export default HomePage;
