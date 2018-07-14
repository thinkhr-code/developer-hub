import { getAccessToken as getAccessTokenFromCookie, getCookie } from '../utils/CookieUtils';

const tokenReducer = (state = {
  accessToken: getAccessTokenFromCookie(),
  shouldSendAuthRequest: false,
  userName: getCookie('userName'),
  userRole: getCookie('userRole'),
  userPermission: getCookie('userPermission'),
}, action) => {
  switch (action.type) {
    case 'FETCH_ACCESS_TOKEN_SUCCESS':
      return {
        ...state,
        isLoading: false,
        error: null,
        accessToken: action.accessToken,
        shouldSendAuthRequest: false,
        userName: action.userName,
        userRole: action.userRole,
        userPermission: action.userPermission,
        ssoUrl: action.ssoUrl
      };
    case 'FETCH_TOKEN_SUCCESS':
      return {
        ...state,
        isLoading: false,
        error: null,
        accessToken: action.accessToken,
        shouldSendAuthRequest: false,
        userName: action.userName,
        userRole: action.userRole,
        userPermission: action.userPermission,
      };
    case 'FETCH_TOKEN_FAIL':
    case 'REMOVE_ACCESS_TOKEN':
    case 'LOGOUT_ACTION':
      return {
        ...state,
        isLoading: false,
        error: null,
        accessToken: null,
      };
    case 'FETCH_ACCESS_TOKEN_FAILED':
      return {
        ...state,
        isLoading: false,
        error: {
          message: `Error: ${action.error}`,
        },
        accessToken: null,
        userName: action.userName,
        userRole: action.userRole,
        userPermission: action.userPermission,
      };
    case 'shouldSendAuthRequest':
      return {
        ...state,
        isLoading: true,
        error: null,
        shouldSendAuthRequest: true,
      };
    default:
      return state;
  }
};

export default tokenReducer;
const isFetchTokenLoading = state => state.tokenReducer.isLoading;
const getFetchTokenError = state => state.tokenReducer.error;
const getAccessToken = state => state.tokenReducer.accessToken;
const shouldSendAuthRequest = state => state.tokenReducer.shouldSendAuthRequest;
const userName = state => state.tokenReducer.userName;
const userRole = state => state.tokenReducer.userRole;
const userPermission = state => state.tokenReducer.userPermission;
const getSsoUrl = state => state.tokenReducer.ssoUrl;

export const selectors = {
  isFetchTokenLoading,
  getFetchTokenError,
  shouldSendAuthRequest,
  getAccessToken,
  userName,
  userRole,
  userPermission,
  getSsoUrl
};
