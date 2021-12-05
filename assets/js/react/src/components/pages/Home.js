import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import styled from "styled-components";

import { SearchService } from "../../services/SearchService";
import { DeckService } from "../../services/Decks";

import TenseSelection from "../common/TenseSelection";

const PageContainer = styled.div`
  display: flex;
  flex-direction: column;
`;

const StudySessionCardContainer = styled.div`
  display: flex;
`;

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

const StudySessionContainer = styled.div`
  display: flex;
  flex: 1;
  flex-direction: column;
  margin: 50pt;
  cursor: pointer;
  justify-content: center;
  min-height: 200pt;
  max-width: 500pt;
  border: 1pt solid;
  border-radius: 10pt;
`;

const StudySessionTitle = styled.span`
  display: flex;
  flex: 1;
  font-weight: bold;
  justify-content: center;
  padding: 10pt;
`;

const PageTitle = styled.h1`
  display: flex;
  font-weight: bold;
  justify-content: center;
  padding: 10pt;
`;

const StudySessionBody = styled.div`
  display: flex;
  flex: 1;
  font-weight: bold;
  justify-content: center;
  padding: 10pt;
`;

const SubmitButton = styled.button`
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 50pt;
  max-width: 200pt;
  max-height: 50pt;
  min-height: 30pt;
  background-color: blue;
  padding: 10pt;
  border: 1pt solid;
  border-radius: 10pt;
  align-self: center;
`;

const HomePage = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [searchResults, setSearchResults] = useState(undefined);
  const [selectedTenses, setSelectedTenses] = useState({});

  const [allTenses, setAllTenses] = useState(false);
  const [pastSimple, setPastSimple] = useState(false);
  const [presentSimple, setPresentSimple] = useState(false);
  const [pastContinuous, setPastContinuous] = useState(false);
  const [presentContinuous, setPresentContinuous] = useState(false);
  const [decks, setDecks] = useState(undefined);

  const navigate = useNavigate();

  useEffect(() => {
    function fetchDecks() {
      DeckService.fetchAll().then(res => {
        console.log(res);
        if (res.data) {
          setDecks(res.data);
        }
      });
    }
    fetchDecks();
  }, []);

  const handleSearch = () => {
    SearchService.search({ hirigana_verb: searchTerm }).then(res => {
      if (res.success) {
        setSearchResults(res.data);
      }
    });
  };

  const handleSession = () => {
    event.preventDefault();
    console.log(selectedTenses);
    const selectedFilters = Object.keys(selectedTenses)
      .filter(tenseFilter => selectedTenses[tenseFilter] === true)
      .map(tenseFilter => `${tenseFilter}=true`)
      .join("&");

    navigate(`/study-sessions?type=custom&${selectedFilters}`);
  };

  const handleDeckStudySession = deckId => {
    navigate(`/study-sessions?type=deck&deck_id=${deckId}`);
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

  const composeConfigMap = (label, id, isChecked, onClick) => {
    return {
      label: label,
      id: id,
      isChecked: isChecked,
      onClick: e => onClick(!isChecked)
    };
  };

  const renderDecks = () => {
    if (!decks) {
      return <p>no decks</p>;
    }

    return decks.map(data => (
      <div>
        <span onClick={() => handleDeckStudySession(data.deck.id)}>
          {data.deck.name}
        </span>
        <span>Cards: {data.card_count}</span>
        <span>Last Used: {data.last_used ? data.last_used : "Not Used"}</span>
      </div>
    ));
  };

  return (
    <PageContainer>
      <PageTitle>Choose Study Session Type</PageTitle>
      <StudySessionCardContainer>
        <StudySessionContainer>
          <StudySessionTitle>YOUR DECKS</StudySessionTitle>
          {renderDecks()}
        </StudySessionContainer>

        <StudySessionContainer>
          <StudySessionTitle>YOUR DECKS</StudySessionTitle>
          <TenseSelection onChange={filters => setSelectedTenses(filters)} />
          <SubmitButton onClick={handleSession}>START SESSION</SubmitButton>
        </StudySessionContainer>
      </StudySessionCardContainer>
      {searchResults && renderSearchResults()}
    </PageContainer>
  );
};
export default HomePage;
