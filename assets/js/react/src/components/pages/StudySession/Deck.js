import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import styled from "styled-components";

import { SearchService } from "../../../services/SearchService";
import { StudySessionService } from "../../../services/StudySession";
import TenseSelection from "../../common/TenseSelection";

const PageContainer = styled.div`
  display: flex;
  flex-direction: column;
`;

const PageTitle = styled.h1`
  display: flex;
  font-weight: bold;
  justify-content: center;
  padding: 10pt;
`;

const ConfigOptionsContainer = styled.div`
  display: flex;
  flex-direction: row;
`;

const ConfigOption = styled.div`
  margin: 5pt;
  border: 1pt solid;
  border-radius: 10pt;
  padding: 10pt;
`;

const TenseOptionsContainer = styled.div`
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

const DeckStudySession = ({ deckId }) => {
  const [selectedTenses, setSelectedTenses] = useState({});

  const [configPolitness, setConfigPolitness] = useState("politnessAll");
  const [configSentenceType, setConfigSentenceType] = useState("positiveAll");

  const navigate = useNavigate();

  const handleStart = () => {
    const data = {
      type: "deck",
      deckId: deckId,
      tenses: selectedTenses,
      filters: { politness: configPolitness, sentenceType: configSentenceType }
    };

    console.log(data);

    StudySessionService.start(data).then(res => {
      if (res.ready) {
        navigate(`/study-sessions/${res.sessionDetails.session_id}`);
      }
    });
  };

  const renderPolitnessOptions = () => {
    return (
      <ConfigOption>
        <h2>Politness Level</h2>
        <label for="polite">Polite forms only</label>
        <input
          checked={configPolitness === "politnessPolite"}
          onClick={e => setConfigPolitness("politnessPolite")}
          type="radio"
          id="polite"
          name="polite"
        />
        <label for="informal">Informal forms only</label>
        <input
          checked={configPolitness === "politnessInformal"}
          onClick={e => setConfigPolitness("politnessInformal")}
          type="radio"
          id="informal"
          name="informal"
        />

        <label for="both">Both</label>
        <input
          checked={configPolitness === "politnessAll"}
          onClick={e => setConfigPolitness("politnessAll")}
          type="radio"
          id="politnessAll"
          name="politnessAll"
        />
      </ConfigOption>
    );
  };

  const renderNegativityOptions = () => {
    return (
      <ConfigOption>
        <h2>Sentence Types</h2>
        <label for="polite">Positive sentences only</label>
        <input
          checked={configSentenceType === "positive"}
          onClick={e => setConfigSentenceType("positive")}
          type="radio"
          id="positive"
          name="positive"
        />
        <label for="negative">Negative sentences only</label>
        <input
          checked={configSentenceType === "negative"}
          onClick={e => setConfigSentenceType("negative")}
          type="radio"
          id="negative"
          name="negative"
        />

        <label for="both">Both</label>
        <input
          checked={configSentenceType === "positiveAll"}
          onClick={e => setConfigSentenceType("positiveAll")}
          type="radio"
          id="positiveAll"
          name="positiveAll"
        />
      </ConfigOption>
    );
  };

  return (
    <PageContainer>
      <PageTitle>Deck Study Session</PageTitle>
      <PageTitle>Configure Session: </PageTitle>
      <ConfigOptionsContainer>
        {renderPolitnessOptions()}
        {renderNegativityOptions()}
      </ConfigOptionsContainer>
      <TenseOptionsContainer>
        <TenseSelection onChange={filters => setSelectedTenses(filters)} />
      </TenseOptionsContainer>
      <button onClick={handleStart}>START</button>
    </PageContainer>
  );
};

export default DeckStudySession;
