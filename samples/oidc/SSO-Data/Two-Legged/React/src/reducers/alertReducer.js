const alertReducer = (state = {
 showTestButton: false,
}, action) => {
  switch (action.type) {
    case 'FETCH_ALERTS_SUCCESS':
      return {
        ...state,
        list: action.list,
        isLoading: false,
        error: null,
      };
    case 'FETCH_ALERTS':
      return {
        ...state,
        isLoading: true,
        error: null,
      };
    case 'FETCH_ALERTS_FAIL':
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

export default alertReducer;

const getAlerts = state => state.alertReducer.list;
const isFetchAlertsLoading = state => state.alertReducer.isLoading;
const getFetchAlertsError = state => state.alertReducer.error;

export const selectors = {
  getAlerts,
  isFetchAlertsLoading,
  getFetchAlertsError,
};
