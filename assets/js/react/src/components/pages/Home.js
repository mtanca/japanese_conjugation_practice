import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import styled from "styled-components";

import { SearchService } from "../../services/SearchService";

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

  const [allTenses, setAllTenses] = useState(false);
  const [pastSimple, setPastSimple] = useState(false);
  const [presentSimple, setPresentSimple] = useState(false);
  const [pastContinuous, setPastContinuous] = useState(false);
  const [presentContinuous, setPresentContinuous] = useState(false);

  const navigate = useNavigate();

  const handleSearch = () => {
    SearchService.search({ hirigana_verb: searchTerm }).then(res => {
      if (res.success) {
        setSearchResults(res.data);
      }
    });
  };

  const handleTenseStudySession = event => {
    event.preventDefault();

    const filters = {
      allTenses: allTenses,
      pastSimple: pastSimple,
      presentSimple: presentSimple,
      pastContinuous: pastContinuous,
      presentContinuous: presentContinuous
    };

    const selectedFilters = Object.keys(filters)
      .filter(tenseFilter => filters[tenseFilter] === true)
      .map(tenseFilter => `${tenseFilter}=true`)
      .join("&");

    navigate(`/study-sessions/tenses?${selectedFilters}`);
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

  const renderTensePracticeCard = () => {
    return (
      <StudySessionContainer>
        <StudySessionTitle>TENSES PRACTICE</StudySessionTitle>
        <StudySessionBody>
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
            onClick={e => setPresentContinuous(!presentContinuous)}
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

          <input
            type="radio"
            id="all"
            name="all_tenses"
            value="all_tenses"
            checked={allTenses}
            onClick={e => {
              setAllTenses(!allTenses);
              setPresentSimple(false);
              setPresentContinuous(false);
              setPastSimple(false);
              setPastContinuous(false);
            }}
          />
          <label for="All Tenses">All Tenses</label>
          <br />
        </StudySessionBody>
        <SubmitButton onClick={handleTenseStudySession}>
          START SESSION
        </SubmitButton>
      </StudySessionContainer>
    );
  };

  return (
    <PageContainer>
      <PageTitle>Choose Study Session Type</PageTitle>
      <StudySessionCardContainer>
        <StudySessionContainer>
          <StudySessionTitle>VOCAB REVIEW</StudySessionTitle>
        </StudySessionContainer>
        {renderTensePracticeCard()}
      </StudySessionCardContainer>

      {searchResults && renderSearchResults()}
    </PageContainer>
  );
};
export default HomePage;
