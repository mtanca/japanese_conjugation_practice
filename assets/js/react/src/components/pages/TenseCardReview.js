import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import styled from "styled-components";

import { StudySessionService } from "../../services/StudySession";

const PageContainer = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
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

  const sessionId = window.location.href.split("sessions/")[1];

  useEffect(() => {
    function startSession() {
      StudySessionService.getSession(sessionId).then(res => {
        console.log(res);
        if (res.card) {
          setShouldStartSession(true);
          setReviewCard(res.card);
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
      if (res.card) {
        setShouldShowAnswer(false);
        setNextCardRequested(!nextCardRequest);
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
      <ReviewCardContainer>
        <ReviewCardTitle>
          <ReviewCardDetail>{question}</ReviewCardDetail>
        </ReviewCardTitle>
        <ReviewCardDetails>
          <ReviewCardDetail>Sentence Type: {reviewCard.form}</ReviewCardDetail>
          <br />
          <ReviewCardDetail>Tense: {reviewCard.tense}</ReviewCardDetail>
          <br />
          <ReviewCardDetail>
            {" "}
            Politness: {reviewCard.politness}
          </ReviewCardDetail>
        </ReviewCardDetails>
        <br />
        <button onClick={e => setShouldShowAnswer(true)}>Show Answer</button>
      </ReviewCardContainer>
    );
  };

  const renderReviewCardAnswer = () => {
    return (
      <ReviewCardContainer>
        <ReviewCardTitle>
          <ReviewCardDetail>{reviewCard.romaji}</ReviewCardDetail>
          <br />
          <ReviewCardDetail>{reviewCard.hirigana}</ReviewCardDetail>
        </ReviewCardTitle>
        <ReviewCardDetails>
          <ReviewCardDetail>Sentence Type: {reviewCard.form}</ReviewCardDetail>
          <ReviewCardDetail>Tense: {reviewCard.tense}</ReviewCardDetail>
          <ReviewCardDetail>
            {" "}
            Politness: {reviewCard.politness}
          </ReviewCardDetail>
        </ReviewCardDetails>
        <br />
        <div>
          <EaseButton
            color={"green"}
            onClick={e => {
              updateAndNextCard("easy");
            }}
          >
            Easy
          </EaseButton>
          <EaseButton
            color={"yellow"}
            onClick={e => {
              updateAndNextCard("medium");
            }}
          >
            Medium
          </EaseButton>
          <EaseButton
            color={"red"}
            onClick={e => {
              updateAndNextCard("hard");
            }}
          >
            Hard
          </EaseButton>
          <EaseButton
            onClick={e => {
              updateAndNextCard("DSA");
            }}
          >
            Don't Show Again
          </EaseButton>
        </div>
      </ReviewCardContainer>
    );
  };

  return (
    <PageContainer>
      {!reviewCard && renderNoCards()}
      {reviewCard && !shouldShowAnswer && renderReviewCardQuestion()}
      {shouldShowAnswer && renderReviewCardAnswer()}
    </PageContainer>
  );
};

export default TenseCardReview;
