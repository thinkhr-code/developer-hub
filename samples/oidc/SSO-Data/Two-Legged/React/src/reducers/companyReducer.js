const companyReducer = (state = {
 showTestButton: false,
}, action) => {
  switch (action.type) {
    case 'FETCH_COMPANIES_SUCCESS':
      return {
        ...state,
        list: action.list,
        isLoading: false,
        error: null,
      };
    case 'FETCH_COMPANIES':
      return {
        ...state,
        isLoading: true,
        error: null,
      };
    case 'FETCH_COMPANIES_FAIL':
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

export default companyReducer;

const getCompanies = state => state.companyReducer.list;
const isFetchCompaniesLoading = state => state.companyReducer.isLoading;
const getFetchCompaniesError = state => state.companyReducer.error;

export const selectors = {
  getCompanies,
  isFetchCompaniesLoading,
  getFetchCompaniesError,
};
