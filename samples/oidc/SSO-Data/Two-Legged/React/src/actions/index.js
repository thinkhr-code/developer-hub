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

export const fetchAlertsAction = () => ({
  type: 'FETCH_ALERTS',
});

export const fetchAlertsSuccess = list => ({
  type: 'FETCH_ALERTS_SUCCESS',
  list,
 });

export const fetchAlertsFail = (errorMessage) => ({
  type: 'FETCH_ALERTS_FAIL',
  error: errorMessage,
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

export const fetchUsersAction = () => ({
  type: 'FETCH_USERS',
});

export const fetchUsersSuccess = list => ({
  type: 'FETCH_USERS_SUCCESS',
  list,
 });

export const fetchUsersFail = (errorMessage) => ({
  type: 'FETCH_USERS_FAIL',
  error: errorMessage,
});

export const fetchAccessToken = () => ({
  type: 'FETCH_ACCESS_TOKEN',
});

export const fetchAccessTokenAction = (mappedValue, userData) => {
  setCookie('userName', userData.user);
  setCookie('userRole', userData.role);
  setCookie('userPermission', userData.permission);
  return {
    type: 'FETCH_ACCESS_TOKEN',
    mappedValue,
    userData,
  }
};

export const errorAction = () => ({
  type: 'ERROR',
});

export const fetchTokenSuccess = (accessToken, userData) => ({
  type: 'FETCH_TOKEN_SUCCESS',
  accessToken,
  userName: userData.user,
  userRole: userData.role,
  userPermission: userData.permission,
});

export const fetchTokenFail = () => ({
  type: 'FETCH_TOKEN_FAIL',
});

export const fetchTokenExpiredAction = () => ({
  type: 'shouldSendAuthRequest',
});

export const fetchAccessTokenSuccess = (resp, userData) => ({
  type: 'FETCH_ACCESS_TOKEN_SUCCESS',
  accessToken: resp.access_token,
  userName: userData.user,
  userRole: userData.role,
  userPermission: userData.permission,

});

export const fetchAccessTokenFailed = (errorMessage, userData) => ({
  type: 'FETCH_ACCESS_TOKEN_FAILED',
  error: errorMessage,
  userName: userData.user,
  userRole: userData.role,
  userPermission: userData.permission,
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
