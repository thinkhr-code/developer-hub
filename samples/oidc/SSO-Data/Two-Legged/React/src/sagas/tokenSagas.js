import { put } from 'redux-saga/effects';
import { fetchRefreshToken, fetchAccessTokenSagaAPI } from '../apis/tokenAPIs';
import { setAccessToken, setRefreshToken } from '../utils/CookieUtils';
import { fetchAccessTokenSuccess, fetchAccessTokenFailed, fetchTokenSuccess } from '../actions';

export function* fetchRefreshTokenSaga(action, authHeading, userData) {
  try {
    const resp = yield fetchRefreshToken(authHeading);
    if (resp) {
      if (resp.access_token) {
        setAccessToken(resp.access_token);
        yield put(fetchTokenSuccess(resp.access_token, userData));
      }
      if (resp.refresh_token) {
        setRefreshToken(resp.refresh_token);
      }
    }
    // Define this actions if you want to save this to the store.
    // yield put(setAccessTokenAction(resp.access_token));
    // yield put(setRefreshTokenAction(resp.refresh_token));
    return resp;
  } catch (e) {
    // Redirect to get auth code.
    //  redirectToAuth();
    return null;
  }
}

export function* fetchAccessTokenSaga(action) {
  try {
    console.log("userdata==========", action.userData);
    const resp = yield fetchAccessTokenSagaAPI(action.mappedValue);
    setAccessToken(resp.access_token);
    setRefreshToken(resp.refresh_token);
    yield put(fetchAccessTokenSuccess(resp, action.userData));
    return resp;
  } catch (e) {
    yield put(fetchAccessTokenFailed(e.message, action.userData));
    return null;
  }
}
