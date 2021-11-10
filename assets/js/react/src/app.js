import React, { useState } from "react";
import * as ReactDOM from "react-dom";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import styled from "styled-components";

import HomePage from "./components/HomePage";

const Container = styled.div`
  display: flex;
  flex: 1;
  border: 1pt solid;
`;

const renderBrowserViewRouter = () => {
  return (
    <Routes>
      <Route expact path="/" element={<HomePage />} />
    </Routes>
  );
};

const AppContainer = () => {
  return <BrowserRouter>{renderBrowserViewRouter()}</BrowserRouter>;
};

ReactDOM.render(<AppContainer />, document.getElementById("react-app"));
