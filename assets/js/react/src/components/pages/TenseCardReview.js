import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import styled from "styled-components";

import { StudySessionService } from "../../services/StudySession";

const PageContainer = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
`;

const SessionStatisticsContainer = styled.div`
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  margin-top: 30pt;
  background-color: red;
`;

const ReviewCardContainer = styled.div`
  display: flex;
  padding: 15pt;
  border: 1pt solid;
  border-radius: 10pt;
  flex-direction: column;
  align-items: center;
  width: 80%;
  height: 40%;
`;

const ReviewCardTitle = styled.div`
  flex: 1;
  font-weight: bold;
`;

const ReviewCardDetails = styled.div`
  flex: 1;
  margin-top: 20pt;
`;

const ReviewCardDetail = styled.span`
  flex: 1;
  color: ${props =>
    props.politness === "Polite"
      ? "green"
      : props.politness === "Plain"
      ? "blue"
      : props.tense === "Past Progressive"
      ? "orange"
      : props.tense === "Past Indicative"
      ? "purple"
      : "black"};
  font-weight: ${props => (props.politness ? "bold" : "none")};
  font-size: 18pt;
`;

const EaseButton = styled.button`
  margin: 5pt;
  background-color: ${props => props.color};
`;

const TenseCardReview = () => {
  const [shouldStartSession, setShouldStartSession] = useState(false);
  const [reviewCard, setReviewCard] = useState(undefined);
  const [shouldShowAnswer, setShouldShowAnswer] = useState(false);
  const [nextCardRequest, setNextCardRequested] = useState(false);
  const [sessionDetails, setSessionDetails] = useState(undefined);

  const sessionId = window.location.href.split("sessions/")[1];

  useEffect(() => {
    function startSession() {
      StudySessionService.getSession(sessionId).then(res => {
        console.log(res);
        if (res.card) {
          setShouldStartSession(true);
          setReviewCard(res.card);
          setSessionDetails(res.sessionDetails);
        }
      });
    }
    startSession();
  }, [nextCardRequest]);

  const updateAndNextCard = ease => {
    StudySessionService.update(sessionId, {
      cardId: reviewCard.id,
      ease: ease
    }).then(res => {
      if (res.sessionDetails) {
        setShouldShowAnswer(false);
        setNextCardRequested(!nextCardRequest);
        setSessionDetails(res.sessionDetails);
      }
    });
  };

  const renderNoCards = () => {
    return <span> No cards to review in this session</span>;
  };

  const renderReviewCardQuestion = () => {
    const question = reviewCard.meaning
      ? reviewCard.meaning
      : reviewCard.romaji;
    return (
      <>
        <ReviewCardTitle>
          <ReviewCardDetail>{question}</ReviewCardDetail>
        </ReviewCardTitle>
        <ReviewCardDetails>
          <ReviewCardDetail tense={reviewCard.tense}>
            {reviewCard.tense} <br />
          </ReviewCardDetail>

          <ReviewCardDetail politness={reviewCard.politness}>
            {reviewCard.politness}
          </ReviewCardDetail>
        </ReviewCardDetails>
        <br />
        <button onClick={e => setShouldShowAnswer(true)}>Show Answer</button>
      </>
    );
  };

  const renderReviewCardAnswer = () => {
    return (
      <>
        <ReviewCardTitle>
          <ReviewCardDetail>{reviewCard.hirigana}</ReviewCardDetail>
          <br />
          <ReviewCardDetail>{reviewCard.romaji}</ReviewCardDetail>
        </ReviewCardTitle>
        <br />
        <div>
          <EaseButton color={"green"} onClick={e => updateAndNextCard("easy")}>
            Easy
          </EaseButton>
          <EaseButton
            color={"yellow"}
            onClick={e => updateAndNextCard("medium")}
          >
            Medium
          </EaseButton>
          <EaseButton color={"red"} onClick={e => updateAndNextCard("hard")}>
            Hard
          </EaseButton>
          <EaseButton onClick={e => updateAndNextCard("DSA")}>
            Don't Show Again
          </EaseButton>
        </div>
      </>
    );
  };

  return (
    <PageContainer>
      {!reviewCard && renderNoCards()}
      <ReviewCardContainer>
        {reviewCard && !shouldShowAnswer && renderReviewCardQuestion()}
        {shouldShowAnswer && renderReviewCardAnswer()}
      </ReviewCardContainer>
      <SessionStatisticsContainer>
        {sessionDetails && <p>Review: {sessionDetails.review_count | 0}</p>}
      </SessionStatisticsContainer>
    </PageContainer>
  );
};

export default TenseCardReview;
