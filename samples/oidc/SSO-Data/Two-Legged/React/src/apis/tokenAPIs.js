import { formPOST, POST } from './HTTP';
import { getRefreshToken } from '../utils/CookieUtils';
import { getAuthorizationHeader, } from '../utils/CommonUtils';

export const fetchRefreshToken = (authHeading) => {
  const url = `${baseUrl}v1/oauth/token`;
  const headers = {
    Authorization: `Basic ${authHeading}`,
  };
  const refreshToken = getRefreshToken();
  const body = new FormData();
  body.append('grant_type', 'refresh_token');
  body.append('refresh_token', refreshToken);
  return formPOST({ url, headers, body });
};

export const fetchAccessTokenSagaAPI = (mappedValue) => {
  const url = `${baseUrl}v1/oauth/identity/token`;
  const body = {
    mappedValue,
    grantType: 'sso',
  };
  const headers = {
    Authorization: `Basic ${getAuthorizationHeader()}`,
  };
  return POST({ url, headers, body });
};
