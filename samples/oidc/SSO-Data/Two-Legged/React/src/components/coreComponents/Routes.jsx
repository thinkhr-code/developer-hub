import React from 'react';
import { Route } from 'react-router-dom';
import SplashPage from '../SplashPage';

const Routes = () => (
  <div>
    <Route exact path="/" component={SplashPage} />
  </div>
);

export default Routes;
