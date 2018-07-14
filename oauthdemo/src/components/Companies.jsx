/* eslint-disable no-script-url */
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import DataGrid from 'simple-react-data-grid';
import { fetchCompaniesAction, fetchTokenSuccess } from '../actions';
import { selectors } from './../reducers/companyReducer';
import { selectors as tokenSelector } from './../reducers/tokenReducer';
import googleLogo from './../images/googlelogo.png';
import { setAuthProvider, getAuthProvider } from './../utils/CookieUtils';

const {getAccessToken, shouldSendAuthRequest, paylocityUserName, paylocityUserRole, paylocityUserPermission} = tokenSelector;
const {isFetchCompaniesLoading, getFetchCompaniesError, getCompanies} = selectors;

class Companies extends Component {
  constructor(props) {
    super(props);
    this.onClickFetchCompaniesButton = this.onClickFetchCompaniesButton.bind(this);
    this.onClickGoogleAuthButton = this.onClickGoogleAuthButton.bind(this);
    this.onClickPaylocityButton = this.onClickPaylocityButton.bind(this);

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
      if (getAuthProvider() === 'google') {
        this.props.onGoogleAuth();
      } if (getAuthProvider() === 'sso') {
        this.props.onPaylocity();
      } if (getAuthProvider() === 'thinkhr') {
        this.props.onAuth();
      }
    }
  }

  getCompaniesData() {
    return (this.props.companies) ? (this.props.companies) : null;
  }

  gridHeaderData() {
    return [
      {
        'name': 'COMPANY NAME',
        'key': 'companyName',
      },
      {
        'name': 'BROKER',
        'key': 'brokerName',
      },
      {
        'name': 'CLIENT TYPE',
        'key': 'companyType',
      },
      {
        'name': 'CONFIGURATION NAME',
        'key': 'configurationName',
      },
    ];
  }

  onClickFetchCompaniesButton() {
    setAuthProvider('thinkhr');
    if (this.props.accessToken) {
      this.props.fetchCompaniesAction();
    } else {
      this.props.onAuth();
    }
  }

  onClickPaylocityButton() {
    setAuthProvider('sso');
    if (this.props.accessToken) {
      this.props.fetchCompaniesAction();
    } else {
      this.props.onPaylocity();
    }
  }

  onClickGoogleAuthButton() {
    setAuthProvider('google');
    if (this.props.accessToken) {
      this.props.fetchCompaniesAction();
    } else {
      this.props.onGoogleAuth();
    }
  }

  renderButton() {
    return (
      <div className="widget-content">
        <div className="container">
          <div className="buttons">
            <div className="thinkHR_user">
              <a href="javascript:void(0)" onClick={this.onClickFetchCompaniesButton} className="primary-button">Get
                Companies
              </a>
              <a href="javascript:void(0)" className="primary-link">Login as ThinkHR User</a>
            </div>
            <div className="thinkHR_user">
              <div style={{ 'display': 'flex' }}>
                <div style={{
                  'alignSelf': 'center',
                  'background': '#1bd5a7',
                  'padding': '7px 0px 7px 5px',
                  'color': '#f8fcf9',
                  'borderRadius': '10px 0 0 10px',
                  'maxWidth': '150px',
                  'margin': '0 auto 10px',
                }}
                >
                  <img
                    style={{
                      'width': '30px',
                      'borderRadius': '15px',
                    }}
                    src={googleLogo}
                  />
                </div>
                <div>
                  <a style={{ 'borderRadius': '0 10px 10px 0', 'paddingLeft': '5px' }} href="javascript:void(0)" onClick={this.onClickGoogleAuthButton} className="primary-button">Get Companies</a>
                </div>
              </div>
              <div>
                <a href="javascript:void(0)" className="primary-link">Login with Google</a>
              </div>
            </div>
            <div className="thinkHR_user">
              <a href="javascript:void(0)" onClick={this.onClickPaylocityButton} className="primary-button">SSO</a>
              <a href="javascript:void(0)" className="primary-link">ThinkHR SSO</a>
            </div>
          </div>
        </div>
      </div>
    );
  }

  renderPaylocityUserInfo() {
    if (this.props.paylocityUserName) {
      return (
        <div className="paylocity-user-info">
          <div className="paylocity-user-type">
            <div>
              User
            </div>
            <div>
              Role
            </div>
            <div>
              Permission
            </div>
          </div>
          <div className="paylocity-user-type-value">
            <div>
              {this.props.paylocityUserName}
            </div>
            <div>
              {this.props.paylocityUserRole}
            </div>
            <div>
              {this.props.paylocityUserPermission}
            </div>
          </div>
        </div>
      )
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
          <div className="info">
            {this.renderButton()}
          </div>
		  {this.renderPaylocityUserInfo()}
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
        <div className="info">
          {this.renderButton()}
        </div>
        {this.renderPaylocityUserInfo()}
        <DataGrid data={this.getCompaniesData()} metadata={this.gridHeaderData()} />
      </section>
    );
  }
}

Companies.propTypes = {
  isLoading: PropTypes.bool,
  companies: PropTypes.array,
  fetchCompaniesAction: PropTypes.func,
  error: PropTypes.object,
  paylocityUserRole: PropTypes.string,
  paylocityUserName: PropTypes.string,
  paylocityUserPermission: PropTypes.string,
};

Companies.defaultProps = {
  isLoading: false,
  companies: [],
  fetchCompaniesAction: () => {
  },
  error: null,
  paylocityUserRole: null,
  paylocityUserName: null,
  paylocityUserPermission: null,
};

const mapStateToProps = state => ({
  isLoading: isFetchCompaniesLoading(state),
  companies: getCompanies(state),
  accessToken: getAccessToken(state),
  error: getFetchCompaniesError(state),
  sendAuthRequest: shouldSendAuthRequest(state),
  paylocityUserName: paylocityUserName(state),
  paylocityUserRole: paylocityUserRole(state),
  paylocityUserPermission: paylocityUserPermission(state),
});

const mapDispatchToProps = dispatch => ({
  fetchCompaniesAction: () => dispatch(fetchCompaniesAction()),
  fetchTokenSuccessAction: () => dispatch(fetchTokenSuccess('testToken')),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(Companies);
