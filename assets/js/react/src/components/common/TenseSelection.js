import React, { useState, useEffect } from "react";
import styled from "styled-components";

import { SearchService } from "../../services/SearchService";
import { DeckService } from "../../services/Decks";

const Container = styled.div`
  display: flex;
`;

const StudySessionTitle = styled.span`
  display: flex;
  flex: 1;
  font-weight: bold;
  justify-content: center;
  padding: 10pt;
`;

const OptionsContainer = styled.div`
  display: flex;
  flex: 1;
  font-weight: bold;
  justify-content: center;
  padding: 10pt;
`;

const TenseSelection = ({ onChange }) => {
  const [allTenses, setAllTenses] = useState(false);
  const [pastSimple, setPastSimple] = useState(false);
  const [presentSimple, setPresentSimple] = useState(false);
  const [pastContinuous, setPastContinuous] = useState(false);
  const [presentContinuous, setPresentContinuous] = useState(false);

  useEffect(() => {
    onChange({
      allTenses: allTenses,
      pastSimple: pastSimple,
      presentSimple: presentSimple,
      pastContinuous: pastContinuous,
      presentContinuous: presentContinuous
    });
  }, [allTenses, pastSimple, presentSimple, pastContinuous, presentContinuous]);

  const handleTenseStudySession = event => {
    event.preventDefault();

    const filters = {
      allTenses: allTenses,
      pastSimple: pastSimple,
      presentSimple: presentSimple,
      pastContinuous: pastContinuous,
      presentContinuous: presentContinuous
    };

    onSumbit(filters);
  };

  const composeConfigMap = (label, id, isChecked, onClick) => {
    return {
      label: label,
      id: id,
      isChecked: isChecked,
      onClick: e => {
        onClick(!isChecked);
      }
    };
  };

  const renderTensePracticeCard = () => {
    const configMap = {
      presentSimple: composeConfigMap(
        "Present Simple",
        "present_simple",
        presentSimple,
        setPresentSimple
      ),
      presentContinuous: composeConfigMap(
        "Present Continuous",
        "present_continuous",
        presentContinuous,
        setPresentContinuous
      ),
      pastSimple: composeConfigMap(
        "Past Simple",
        "past_simple",
        pastSimple,
        setPastSimple
      ),
      pastContinuous: composeConfigMap(
        "Past Continuous",
        "past_continuous",
        pastContinuous,
        setPastContinuous
      )
    };

    return (
      <OptionsContainer>
        {Object.keys(configMap).map(key => (
          <>
            <input
              type="radio"
              id={configMap[key].id}
              name={configMap[key].id}
              checked={configMap[key].isChecked}
              onClick={configMap[key].onClick}
            />
            <label for={configMap[key].id}>{configMap[key].label}</label>
          </>
        ))}
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
      </OptionsContainer>
    );
  };

  return <Container>{renderTensePracticeCard()}</Container>;
};
export default TenseSelection;
