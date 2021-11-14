import React, { useState } from "react";
import * as ReactDOM from "react-dom";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import styled from "styled-components";

import HomePage from "./components/pages/Home";
import TenseStudySessionPage from "./components/pages/TenseStudySession";
import TenseCardReview from "./components/pages/TenseCardReview";

const Container = styled.div`
  display: flex;
  flex: 1;
  border: 1pt solid;
`;

const renderBrowserViewRouter = () => {
  return (
    <Routes>
      <Route expact path="/" element={<HomePage />} />
      <Route
        expact
        path="/study-sessions/tenses"
        element={<TenseStudySessionPage />}
      />
      <Route path="/study-sessions/:sessionId" element={<TenseCardReview />} />
    </Routes>
  );
};

const AppContainer = () => {
  return <BrowserRouter>{renderBrowserViewRouter()}</BrowserRouter>;
};

ReactDOM.render(<AppContainer />, document.getElementById("react-app"));
