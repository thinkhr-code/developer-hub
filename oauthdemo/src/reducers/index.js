import { combineReducers } from 'redux';
import companyReducer from './companyReducer';
import token from './tokenReducer';

export default combineReducers({
  companyReducer,
  token,
});
