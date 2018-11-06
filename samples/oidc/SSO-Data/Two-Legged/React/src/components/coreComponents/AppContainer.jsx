import React from 'react';
import { HashRouter } from 'react-router-dom';

import Routes from './Routes';

const AppContainer = () => (
  <HashRouter>
    <Routes />
  </HashRouter>
);

export default AppContainer;
