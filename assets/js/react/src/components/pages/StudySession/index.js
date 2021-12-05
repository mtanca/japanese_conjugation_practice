import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import styled from "styled-components";

import CustomStudySession from "./Custom";
import DeckStudySessionPage from "./Deck";

import { StudySessionService } from "../../../services/StudySession";

const PageContainer = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
`;

const StudySessionPage = () => {
  const params = window.location.href
    .split("sessions?")[1]
    .split("&")
    .reduce((prev, next) => {
      const [k, v] = next.split("=");
      return { ...prev, [k]: v };
    }, {});

  console.log(params);

  useEffect(() => {
    function startSession() {}
    startSession();
  }, []);

  return (
    <PageContainer>
      {params.type === "custom" ? (
        <CustomStudySession />
      ) : params.type === "deck" ? (
        <DeckStudySessionPage deckId={params.deck_id} />
      ) : null}
    </PageContainer>
  );
};

export default StudySessionPage;
