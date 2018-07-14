import { formPOST, formGET, POST, GET } from './HTTP';
import { getRefreshToken } from '../utils/CookieUtils';
import {
  getClientId,
  getClientSecret,
  getReturnURL,
  getPaylocityAuthorizationHeader,
  getGoogleAuthorizationHeader
} from '../utils/CommonUtils';

export const fetchAccessToken = () => {
  const url = `${baseUrl}v1/oauth/token`;
  const headers = {
    Authorization: 'Basic MGRkM2U2ZDk6YThmMTNkNzU2MjVmMGExYTQyZDhmYWFlODUxNTBjNGE=',
  };

  const body = new FormData();
  body.append('grant_type', 'password');
  body.append('username', 'skaki@thinkhr.com');
  body.append('password', 'TryThis1$');
  return formPOST({url, headers, body});
};

export const fetchRefreshToken = (authHeading) => {
  const url = `${baseUrl}v1/oauth/token`;
  const headers = {
    Authorization: `Basic ${authHeading}`,
  };
  const refreshToken = getRefreshToken();
  const body = new FormData();
  body.append('grant_type', 'refresh_token');
  body.append('refresh_token', refreshToken);
  return formPOST({url, headers, body});
};

export const fetchAccessTokenFromCode = (code) => {
  const url = `${baseUrl}v1/oauth/token`;
  const headers = {
    Authorization: 'Basic MGRkM2U2ZDk6YThmMTNkNzU2MjVmMGExYTQyZDhmYWFlODUxNTBjNGE=',
  };
  const body = new FormData();
  body.append('grant_type', 'authorization_code');
  body.append('code', code);
  body.append('redirect_uri', getReturnURL());
  body.append('client_secret', getClientSecret());
  body.append('client_id', getClientId());
  return formPOST({url, headers, body});
};

export const fetchAuthCode = () => {
  const url = `${baseUrl}v1/oauth/authorize`;
  const headers = {};
  const body = new FormData();
  body.append('response_type', 'code');
  body.append('client_id', '0dd3e6d9');
  body.append('redirect_uri', getReturnURL());
  body.append('scope', 'all');
  return formGET({url, headers, body});
};

export const fetchGoogleAccessTokenCode = (code) => {
  try {
    const url = 'https://www.googleapis.com/oauth2/v3/token';
    const headers = {
      Authorization: 'Basic MTAxMTYzNDk2Mzc4LWc0cm9tbWltcXQ1NWExbTZvbTAxYW90cDJjM3RhamtqLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tOlpEem5Vb0Rzb2xTZ2JQS2duM1J3eThETg==',
      "Content-Type": "application/x-www-form-urlencoded"
    };
    const returnUrl = getReturnURL();
    let body = `grant_type=authorization_code&code=${code}&redirect_uri=${encodeURIComponent(returnUrl)}&client_secret=ZDznUoDsolSgbPKgn3Rwy8DN&client_id=101163496378-g4rommimqt55a1m6om01aotp2c3tajkj.apps.googleusercontent.com`;
    return formPOST({url, headers, body});
  } catch (e) {
    console.log(e);
  }
};

export const fetchPaylocityAccessTokenSagaAPI = (mappedValue) => {
  const url = `${baseUrl}v1/oauth/identity/token`;
  const body = {
    mappedValue,
    grantType: 'sso',
  };
  const headers = {
    Authorization: `Basic ${getPaylocityAuthorizationHeader()}`,
  };
  return POST({url, headers, body});
};

export const fetchExchangeGoogleAccessTokenAPI = (accessToken, idToken) => {
  const url = `${baseUrl}v1/oauth/identity/token`;
  const body = {
    accessToken,
    idToken,
    grantType: 'openid',
	companyId: '232220',
  };
  const headers = {
    Authorization: `Basic ${getGoogleAuthorizationHeader()}`,
  };
  return POST({url, headers, body});

};