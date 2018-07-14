import { getAccessToken as getAccessTokenFromCookie, getCookie } from '../utils/CookieUtils';

const token = (state = {
  accessToken: getAccessTokenFromCookie(),
  shouldSendAuthRequest: false,
  paylocityUserName: getCookie('userName'),
  paylocityUserRole: getCookie('userRole'),
  paylocityUserPermission: getCookie('userPermission'),
}, action) => {
  switch (action.type) {
    case 'FETCH_TOKEN_SUCCESS':
    case 'FETCH_PAYLOCITY_ACCESS_TOKEN_SUCCESS':
    case 'FETCH_EXCHANGE_GOOGLE_ACCESS_TOKEN_SUCCESS':
      return {
        ...state,
        accessToken: action.accessToken,
        shouldSendAuthRequest: false,
        paylocityUserName: action.userName,
        paylocityUserRole: action.userRole,
        paylocityUserPermission: action.userPermission,
      };
    case 'FETCH_SSO_TOKEN_SUCCESS':
      return {
        ...state,
        accessToken: action.accessToken,
        shouldSendAuthRequest: false,
        paylocityUserName: action.userName,
        paylocityUserRole: action.userRole,
        paylocityUserPermission: action.userPermission,
      };
    case 'FETCH_TOKEN_FAIL':
    case 'FETCH_EXCHANGE_GOOGLE_ACCESS_TOKEN_FAILED':
    case 'REMOVE_ACCESS_TOKEN':
    case 'LOGOUT_ACTION':
      return {
        ...state,
        accessToken: null,
      };
    case 'FETCH_PAYLOCITY_ACCESS_TOKEN_FAILED':
      return {
        ...state,
        accessToken: null,
        paylocityUserName: action.userName,
        paylocityUserRole: action.userRole,
        paylocityUserPermission: action.userPermission,
      };
    case 'shouldSendAuthRequest':
      return {
        ...state,
        shouldSendAuthRequest: true,
      };
    case 'SET_GOOGLE_REFRESH_TOKEN':
      return {
        ...state,
        googleRefreshToken: action.token,
      };
    case 'SET_GOOGLE_ID_TOKEN':
      return {
        ...state,
        googleIdToken: action.token,
      };
    case 'SET_GOOGLE_ACCESS_TOKEN':
      return {
        ...state,
        googleAccessToken: action.token,
      };
    default:
      return state;
  }
};

export default token;
const getAccessToken = state => state.token.accessToken;
const shouldSendAuthRequest = state => state.token.shouldSendAuthRequest;
const paylocityUserName = state => state.token.paylocityUserName;
const paylocityUserRole = state => state.token.paylocityUserRole;
const paylocityUserPermission = state => state.token.paylocityUserPermission;

export const selectors = {
  shouldSendAuthRequest,
  getAccessToken,
  paylocityUserName,
  paylocityUserRole,
  paylocityUserPermission,
};
