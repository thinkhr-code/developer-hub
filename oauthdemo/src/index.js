import React from 'react';
import ReactDOM from 'react-dom';
import { applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import createSagaMiddleware from 'redux-saga';
import { all } from 'redux-saga/effects';

import logger from 'redux-logger';
import AppContainer from './components/coreComponents/AppContainer';
import sagas from './sagas';

import rootReducer from './reducers';
import './style.css';

const sagaMiddleware = createSagaMiddleware();

const middleware = [
  sagaMiddleware,
];
if (process.env.NODE_ENV === 'development') {
  middleware.push(logger);
}
const store = createStore(rootReducer, applyMiddleware(...middleware));

function* sagaWatchers() {
  yield all([
    sagas,
  ]);
}
sagaMiddleware.run(sagaWatchers);

ReactDOM.render(
// eslint-disable-next-line react/jsx-filename-extension
  <Provider store={store}>
    <AppContainer />
  </Provider>, document.getElementById('thinkHRWidget'));

