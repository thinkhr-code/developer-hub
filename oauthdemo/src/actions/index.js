/* eslint-disable no-plusplus */
import { deleteCookie, setCookie } from '../utils/CookieUtils';

let nextTodoId = 0;
export const addTodo = text => ({
  type: 'ADD_TODO',
  id: nextTodoId++,
  text,
});

export const setVisibilityFilter = filter => ({
  type: 'SET_VISIBILITY_FILTER',
  filter,
});

export const toggleTodo = id => ({
  type: 'TOGGLE_TODO',
  id,
});

export const VisibilityFilters = {
  SHOW_ALL: 'SHOW_ALL',
  SHOW_COMPLETED: 'SHOW_COMPLETED',
  SHOW_ACTIVE: 'SHOW_ACTIVE',
};

export const showTestButtonAction = () => ({
  type: 'SHOW_TEST_BUTTON',
});

export const hideTestButtonAction = () => ({
  type: 'HIDE_TEST_BUTTON',
});

export const setTestAPIResponseAction = data => ({
  type: 'SET_TEST_API_RESPONSE',
  respData: data,
});

export const fetchTestAPIData = url => ({
  type: 'FETCH_TEST_API_DATA',
  url,
});

export const fetchCompaniesAction = () => ({
  type: 'FETCH_COMPANIES',
});

export const fetchCompaniesSuccess = list => ({
  type: 'FETCH_COMPANIES_SUCCESS',
  list,
});

export const fetchCompaniesFail = (errorMessage) => ({
  type: 'FETCH_COMPANIES_FAIL',
  error: errorMessage,
});

export const fetchAccessToken = () => ({
  type: 'FETCH_ACCESS_TOKEN',
});

export const fetchGoogleAccessTokenAction = code => ({
  type: 'FETCH_GOOGLE_ACCESS_TOKEN',
  code,
});

export const fetchPaylocityAccessTokenAction = (mappedValue, userData) => {
  setCookie('userName', userData.user);
  setCookie('userRole', userData.role);
  setCookie('userPermission', userData.permission);
  return {
    type: 'FETCH_PAYLOCITY_ACCESS_TOKEN',
    mappedValue,
    userData,
  }
};

export const fetchAccessTokenFromCodeAction = code => ({
  type: 'FETCH_ACCESS_TOKEN_FROM_CODE',
  code,
});

export const errorAction = () => ({
  type: 'ERROR',
});

export const fetchTokenSuccess = (accessToken) => ({
  type: 'FETCH_TOKEN_SUCCESS',
  accessToken,
});

export const fetchSsoTokenSuccess = (accessToken, caseSSO) => ({
  type: 'FETCH_SSO_TOKEN_SUCCESS',
  accessToken,
  userName: caseSSO.user,
  userRole: caseSSO.role,
  userPermission: caseSSO.permission,
});

export const fetchTokenFail = () => ({
  type: 'FETCH_TOKEN_FAIL',
});

export const fetchTokenExpiredAction = () => ({
  type: 'shouldSendAuthRequest',
});

export const setGoogleRefreshToken = token => ({
  type: 'SET_GOOGLE_REFRESH_TOKEN',
  token,
});

export const setGoogleAccessToken = token => ({
  type: 'SET_GOOGLE_ACCESS_TOKEN',
  token,
});

export const setGoogleIdToken = token => ({
  type: 'SET_GOOGLE_ID_TOKEN',
  token,
});

export const fetchPaylocityAccessTokenSuccess = (resp, userData) => ({
  type: 'FETCH_PAYLOCITY_ACCESS_TOKEN_SUCCESS',
  accessToken: resp.access_token,
  userName: userData.user,
  userRole: userData.role,
  userPermission: userData.permission,

});

export const fetchExchangeGoogleAccessTokenSuccess = resp => ({
  type: 'FETCH_EXCHANGE_GOOGLE_ACCESS_TOKEN_SUCCESS',
  accessToken: resp.access_token,
});

export const fetchPaylocityAccessTokenFailed = (errorMessage, userData) => ({
  type: 'FETCH_PAYLOCITY_ACCESS_TOKEN_FAILED',
  error: errorMessage,
  userName: userData.user,
  userRole: userData.role,
  userPermission: userData.permission,
});

export const fetchExchangeGoogleAccessTokenFailed = errorMessage => ({
  type: 'FETCH_EXCHANGE_GOOGLE_ACCESS_TOKEN_FAILED',
  error: errorMessage,
});

export const removeAccessTokenAction = () => ({
  type: 'REMOVE_ACCESS_TOKEN',
});

export const logoutAction = () => {
  deleteCookie('THINKHR_ACCESS_TOKEN');
  deleteCookie('THINKHR_REFRESH_TOKEN');
  deleteCookie('userName');
  deleteCookie('userRole');
  deleteCookie('userPermission');
  deleteCookie('AUTH_PROVIDER');

  window.sessionStorage.clear();
  alert('You are logged out successfully');
  window.location.reload();
  return {
    type: 'LOGOUT_ACTION',
  };
};
