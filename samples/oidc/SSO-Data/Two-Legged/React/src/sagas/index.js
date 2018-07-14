import { takeLatest } from 'redux-saga/effects';
import { fetchAlertsSaga } from './alertsSagas';
import { fetchCompaniesSaga } from './companiesSagas';
import { fetchUsersSaga } from './usersSagas';
import { fetchAccessTokenSaga } from './tokenSagas';

const sagas = [
  takeLatest('FETCH_ALERTS', fetchAlertsSaga),
  takeLatest('FETCH_COMPANIES', fetchCompaniesSaga),
  takeLatest('FETCH_USERS', fetchUsersSaga),
  takeLatest('FETCH_ACCESS_TOKEN', fetchAccessTokenSaga)
];

export default sagas;
