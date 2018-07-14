import { put } from 'redux-saga/effects';
import { fetchCompanies } from './../apis/countryAPIs';
import { fetchAccessTokenSaga, fetchAuthCodeSaga, fetchRefreshTokenSaga } from './tokenSagas';
import { fetchCompaniesSuccess, removeAccessTokenAction, fetchCompaniesFail, fetchTokenExpiredAction } from './../actions';
import { getAccessToken, getAuthProvider, getCookie } from '../utils/CookieUtils';
import { getGoogleAuthorizationHeader, getPaylocityAuthorizationHeader, getThinkhrAuthorizationHeader } from '../utils/CommonUtils';

export function* fetchCompaniesSaga(action) {
  try {
    const accessToken = getAccessToken();
    if (!accessToken) {
      throw new Error('emptyToken');
    }
    if (accessToken) {
      const resp = yield fetchCompanies();
      if (resp) {
        yield put(fetchCompaniesSuccess(resp.companies));
      }
    } else {
      // No access Token available trying to fetch new access token. Component should submit the auth form
      yield put(fetchCompaniesFail());
      yield put(removeAccessTokenAction());
    }
  } catch (e) {
    console.log(e);
    // If access token is invalid
    const authProvider = getAuthProvider();
    if (e.error === 'invalid_token' || e.message === 'emptyToken') {
      if (authProvider === 'thinkhr') {
        const authHeading = getThinkhrAuthorizationHeader();
        const tokenResp = yield fetchRefreshTokenSaga(action, authHeading);
        if (tokenResp) {
          yield fetchCompaniesSaga(action);
        } else {
          // Redirect to get auth code.
          yield put(fetchTokenExpiredAction());
        }
      } if (authProvider === 'google') {
        const authHeading = getGoogleAuthorizationHeader();
        const tokenResp = yield fetchRefreshTokenSaga(action, authHeading);
        if (tokenResp) {
          yield fetchCompaniesSaga(action);
        } else {
          // Redirect to get auth code.
          yield put(fetchTokenExpiredAction());
        }
      } if (authProvider === 'sso') {
        const caseSSO = {
          'user': getCookie('userName'),
          'role': getCookie('userRole'),
          'permission': getCookie('userPermission'),
        };
        const authHeading = getPaylocityAuthorizationHeader();
        const tokenResp = yield fetchRefreshTokenSaga(action, authHeading, caseSSO);
        if (tokenResp) {
          yield fetchCompaniesSaga(action);
        } else {
          // Redirect to get auth code.
          yield put(fetchTokenExpiredAction());
        }
      }
    } else {
      // Some other(non auth) error in the API
      yield put(fetchCompaniesFail(e.message));
    }
  }
}

