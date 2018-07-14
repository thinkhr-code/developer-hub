import { combineReducers } from 'redux';
import alertReducer from './alertReducer';
import companyReducer from './companyReducer';
import userReducer from './userReducer';
import tokenReducer from './tokenReducer';

export default combineReducers({
  alertReducer,
  companyReducer,
  userReducer,
  tokenReducer,
});
