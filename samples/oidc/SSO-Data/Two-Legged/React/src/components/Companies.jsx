/* eslint-disable no-script-url */
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import DataGrid from './DataGrid';
import { fetchCompaniesAction, fetchTokenSuccess } from './../actions';
import { selectors } from './../reducers/companyReducer';
import { selectors as tokenSelector } from './../reducers/tokenReducer';
import { setAuthProvider, getAuthProvider } from './../utils/CookieUtils';

const {
  getAccessToken,
  shouldSendAuthRequest,
  userName,
  userRole,
  userPermission,
  getSsoUrl,
} = tokenSelector;
const { isFetchCompaniesLoading, getFetchCompaniesError, getCompanies } = selectors;

class Companies extends Component {
  constructor(props) {
    super(props);
  }

  componentWillMount() {
    if (this.props.accessToken) {
      this.props.fetchCompaniesAction();
    }
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.accessToken && (this.props.accessToken !== nextProps.accessToken)) {
      nextProps.fetchCompaniesAction();
    }
    if (!this.props.sendAuthRequest && nextProps.sendAuthRequest) {
        this.props.onUserSelect();
    }
  }

  getCompaniesData() {
    return (this.props.companies) ? (this.props.companies) : null;
  }

  gridHeaderData() {
    return [
      {
        'name': 'ID',
        'key': 'companyId',
      },
      {
        'name': 'NAME',
        'key': 'companyName',
      },
      {
        'name': 'PHONE',
        'key': 'companyPhone',
      },
      {
        'name': 'SINCE',
        'key': 'companySince',
      },
    ];
  }

  onClickButton() {
    setAuthProvider('sso');
    if (this.props.accessToken) {
      this.props.fetchCompaniesAction();
    }
  }
  
  render() {
    if (this.props.isLoading) {
      return (
        <section className="all">
          <div style={{
            'display': 'flex',
            'justifyContent': 'center',
            'minHeight': '200px',
            'alignItems': 'center',
          }}
          >
            Loading...
          </div>
        </section>
      );
    }
    if (this.props.error && this.props.error.message) {
      return (
        <section className="all">
          <div style={{
            'padding': '20px',
            'marginTop': '10px',
            'backgroundColor': '#f7caca',
          }}
          >{this.props.error.message}
          </div>
        </section>
      );
    }
    return (
      <section className="all">
        <DataGrid typeName={"COMPANY "} data={this.getCompaniesData()} metadata={this.gridHeaderData()} />
      </section>
    );
  }
}

Companies.propTypes = {
  isLoading: PropTypes.bool,
  companies: PropTypes.array,
  fetchCompaniesAction: PropTypes.func,
  error: PropTypes.object,
  userRole: PropTypes.string,
  userName: PropTypes.string,
  userPermission: PropTypes.string,
};

Companies.defaultProps = {
  isLoading: false,
  companies: [],
  fetchCompaniesAction: () => {
  },
  error: null,
  userRole: null,
  userName: null,
  userPermission: null,
};

const mapStateToProps = state => ({
  isLoading: isFetchCompaniesLoading(state),
  companies: getCompanies(state),
  accessToken: getAccessToken(state),
  error: getFetchCompaniesError(state),
  sendAuthRequest: shouldSendAuthRequest(state),
  userName: userName(state),
  userRole: userRole(state),
  userPermission: userPermission(state),
  ssoUrl: getSsoUrl(state),
});

const mapDispatchToProps = dispatch => ({
  fetchCompaniesAction: () => dispatch(fetchCompaniesAction()),
  fetchTokenSuccessAction: () => dispatch(fetchTokenSuccess('testToken')),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(Companies);
