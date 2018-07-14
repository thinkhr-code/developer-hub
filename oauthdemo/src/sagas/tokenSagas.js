import { put } from 'redux-saga/effects';
import {
  fetchAccessToken,
  fetchRefreshToken,
  fetchAccessTokenFromCode,
  fetchAuthCode,
  fetchExchangeGoogleAccessTokenAPI,
  fetchGoogleAccessTokenCode,
  fetchPaylocityAccessTokenSagaAPI,
} from './../apis/tokenAPIs';
import { setAccessToken, setRefreshToken } from '../utils/CookieUtils';
import { getReturnURL } from '../utils/CommonUtils';
import {
  fetchTokenSuccess,
  setGoogleAccessToken,
  setGoogleRefreshToken,
  setGoogleIdToken,
  fetchExchangeGoogleAccessTokenSuccess,
  fetchExchangeGoogleAccessTokenFailed,
  fetchPaylocityAccessTokenSuccess, fetchPaylocityAccessTokenFailed, fetchSsoTokenSuccess,
} from '../actions';

export function* fetchRefreshTokenSaga(action, authHeading, caseSSO) {
  try {
    const resp = yield fetchRefreshToken(authHeading);
    if (resp) {
      if (resp.access_token) {
        setAccessToken(resp.access_token);
        if (caseSSO) {
          yield put(fetchSsoTokenSuccess(resp.access_token, caseSSO));
        } else {
          yield put(fetchTokenSuccess(resp.access_token));
        }
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
    const resp = yield fetchAccessToken();

    if (resp) {

      if (resp.access_token) {
        setAccessToken(resp.access_token);
        yield put(fetchTokenSuccess(resp.access_token));
      }
      if (resp.refresh_token) {
        setRefreshToken(resp.refresh_token);
      }
    }
    return resp;
    // yield put(setAccessTokenAction(resp.access_token));
    // yield put(setRefreshTokenAction(resp.refresh_token));
  } catch (e) {
    // Redirect to get auth code.
    // redirectToAuth();
    return null;
  }
}

export function* fetchAccessTokenFromCodeSaga(action) {
  try {
    const resp = yield fetchAccessTokenFromCode(action.code);

    if (resp) {

      if (resp.access_token) {
        setAccessToken(resp.access_token);
        yield put(fetchTokenSuccess(resp.access_token));
      }
      if (resp.refresh_token) {
        setRefreshToken(resp.refresh_token);
      }
    }

    // Hack: Refresh the app to remove auth code from url param.
    window.location = getReturnURL();

    return resp;
    // yield put(setAccessTokenAction(resp.access_token));
    // yield put(setRefreshTokenAction(resp.refresh_token));
  } catch (e) {
    // Redirect to get auth code.
    // redirectToAuth();
    return null;
  }
}

export function* fetchPaylocityAccessTokenSaga(action) {
  try {
    console.log("userdata==========", action.userData);
    const resp = yield fetchPaylocityAccessTokenSagaAPI(action.mappedValue);
    setAccessToken(resp.access_token);
    setRefreshToken(resp.refresh_token);
    yield put(fetchPaylocityAccessTokenSuccess(resp, action.userData));
    return resp;
  } catch (e) {
    yield put(fetchPaylocityAccessTokenFailed(e.message, action.userData));
    return null;
  }
}

export function* fetchExchangeGoogleAccessTokenSaga(accessToken, idToken) {
  try {
    const resp = yield fetchExchangeGoogleAccessTokenAPI(accessToken, idToken);
    setAccessToken(resp.access_token);
    setRefreshToken(resp.refresh_token);
    yield put(fetchExchangeGoogleAccessTokenSuccess(resp));
    return resp;
  } catch (e) {
    yield put(fetchExchangeGoogleAccessTokenFailed(e.message));
    return null;
  }
}

export function* fetchAuthCodeSaga(action) {
  try {
    const resp = yield fetchAuthCode();
    if (resp) {
      /*yield fetchAccessTokenFromCodeSaga({
        code: resp.code,
      });*/
    }
    return resp;
  } catch (e) {
    return null;
  }
}

export function* fetchGoogleAccessTokenSaga(action) {
  try {
    const resp = yield fetchGoogleAccessTokenCode(action.code);

    if (resp) {
      if (resp.refresh_token) {
        yield put(setGoogleRefreshToken(resp.refresh_token));
      }
      if (resp.id_token) {
        yield put(setGoogleIdToken(resp.id_token));
      }
      if (resp.access_token) {
        yield fetchExchangeGoogleAccessTokenSaga(resp.access_token, resp.id_token);
        yield put(setGoogleAccessToken(resp.access_token));
      }
    }
    return resp;
  } catch (e) {
    return null;
  }
}