import { takeLatest } from 'redux-saga/effects';
import { fetchCompaniesSaga } from './companiesSagas';
import {
  fetchAccessTokenSaga,
  fetchAccessTokenFromCodeSaga,
  fetchPaylocityAccessTokenSaga,
  fetchExchangeGoogleAccessTokenSaga,
  fetchGoogleAccessTokenSaga,
} from './tokenSagas';

const sagas = [
  takeLatest('FETCH_COMPANIES', fetchCompaniesSaga),
  takeLatest('FETCH_ACCESS_TOKEN', fetchAccessTokenSaga),
  takeLatest('FETCH_ACCESS_TOKEN_FROM_CODE', fetchAccessTokenFromCodeSaga),
  takeLatest('FETCH_PAYLOCITY_ACCESS_TOKEN', fetchPaylocityAccessTokenSaga),
  takeLatest('FETCH_EXCHANGE_GOOGLE_ACCESS_TOKEN', fetchExchangeGoogleAccessTokenSaga),
  takeLatest('FETCH_GOOGLE_ACCESS_TOKEN', fetchGoogleAccessTokenSaga),


];

export default sagas;
