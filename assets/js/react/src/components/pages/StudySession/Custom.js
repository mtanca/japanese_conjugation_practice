import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import styled from "styled-components";

import { SearchService } from "../../../services/SearchService";
import { StudySessionService } from "../../../services/StudySession";

const PageContainer = styled.div`
  display: flex;
  flex-direction: column;
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

const VerbSelectionContainer = styled.div`
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  height: 400pt;
  overflow: auto;
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

const PageTitle = styled.h1`
  display: flex;
  font-weight: bold;
  justify-content: center;
  padding: 10pt;
`;

const VerbSelection = styled.tr`
  display: flex;
  padding: 10pt;
  border: 1pt solid;
`;

const CustomStudySession = props => {
  const urlParams = window.location.href
    .split("sessions?")[1]
    .split("&")
    .reduce((prev, next) => {
      const [k, v] = next.split("=");
      return { ...prev, [k]: v };
    }, {});

  const [verbsList, setVerbsList] = useState(undefined);
  const [selectedVerbs, setSelectedVerbsList] = useState({});
  const [configPolitness, setConfigPolitness] = useState("politnessAll");
  const [configSentenceType, setConfigSentenceType] = useState("positiveAll");

  const navigate = useNavigate();

  const handleAllVerbFetch = () => {
    SearchService.fetchAll().then(res => {
      if (res.data) {
        setVerbsList(res.data);
      }
    });
  };

  const hanndleVerbSelection = event => {
    const targetId = event.target.id;

    selectedVerbs[targetId] = true;
    setSelectedVerbsList(selectedVerbs);
  };

  const handleStart = () => {
    delete urlParams.type;
    const data = {
      type: "custom",
      tenses: urlParams,
      verbs: selectedVerbs,
      filters: { politness: configPolitness, sentenceType: configSentenceType }
    };

    console.log(data);

    StudySessionService.start(data).then(res => {
      if (res.ready) {
        navigate(`/study-sessions/${res.sessionDetails.session_id}`);
      }
    });
  };

  const renderVerbSelection = verb => {
    const name = `${verb.romaji}-${verb.plain_base}`;
    return (
      <VerbSelection id={name}>
        <td>{verb.romaji}</td>
        <td>{verb.plain_base}</td>
        <td>{verb.meaning}</td>
        <td>
          <input
            onClick={e => hanndleVerbSelection(e)}
            type="radio"
            id={name}
            name={name}
          />
        </td>
      </VerbSelection>
    );
  };

  const renderVerbsListSelection = () => {
    return (
      <VerbSelectionContainer>
        <table>
          <VerbSelection>
            <th>Romaji</th>
            <th>Hirigana</th>
            <th>Meaning</th>
          </VerbSelection>
          {verbsList.map(verb => renderVerbSelection(verb))}
        </table>
      </VerbSelectionContainer>
    );
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

  const handleRandomizer = () => {
    handleAllVerbFetch();

    for (var i = 0; i < 10; i++) {
      const verb = verbsList[Math.floor(Math.random() * verbsList.length)];
      const name = `${verb.romaji}-${verb.plain_base}`;

      selectedVerbs[name] = true;
      setSelectedVerbsList(selectedVerbs);
    }
    handleStart();
  };

  return (
    <PageContainer>
      <PageTitle>Tense Study Session</PageTitle>
      <PageTitle>Configure Session: </PageTitle>
      <ConfigOptionsContainer>
        {renderPolitnessOptions()}
        {renderNegativityOptions()}
      </ConfigOptionsContainer>
      <button onClick={handleRandomizer}>Randomizer</button>
      <button onClick={handleAllVerbFetch}>SELECT FROM LIST</button>
      {verbsList && renderVerbsListSelection()}
      {verbsList && <button onClick={handleStart}>START</button>}
    </PageContainer>
  );
};

export default CustomStudySession;
