const userReducer = (state = {
 showTestButton: false,
}, action) => {
  switch (action.type) {
    case 'FETCH_USERS_SUCCESS':
      return {
        ...state,
        list: action.list,
        isLoading: false,
        error: null,
      };
    case 'FETCH_USERS':
      return {
        ...state,
        isLoading: true,
        error: null,
      };
    case 'FETCH_USERS_FAIL':
    case 'FETCH_ACCESS_TOKEN_FAILED':
      return {
        ...state,
        isLoading: false,
        error: {
          message: `Error: ${action.error}`,
        },
      };
    default:
      return state;
  }
};

export default userReducer;

const getUsers = state => state.userReducer.list;
const isFetchUsersLoading = state => state.userReducer.isLoading;
const getFetchUsersError = state => state.userReducer.error;

export const selectors = {
  getUsers,
  isFetchUsersLoading,
  getFetchUsersError,
};
