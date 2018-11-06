/* eslint-disable no-script-url */
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { fetchTokenSuccess } from './../actions';
import { selectors as tokenSelector } from './../reducers/tokenReducer';
import { setAuthProvider, getAuthProvider } from './../utils/CookieUtils';

const {
  isFetchTokenLoading,
  getFetchTokenError,
  getAccessToken,
  shouldSendAuthRequest,
  userName,
  userRole,
  userPermission,
  getSsoUrl,
} = tokenSelector;

class UserInfo extends Component {
  constructor(props) {
    super(props);
    this.onClickButton = this.onClickButton.bind(this);
  }

  getUserInfoData() {

    return (this.props.alerts) ? (this.props.alerts) : null;
  }

  onClickButton() {
    setAuthProvider('sso');
    if (!this.props.accessToken) {
      this.props.onUserSelect();
    }
  }

  renderButton() {
    return (
      <div className="widget-content">
        <div className="container">
          <div className="buttons">
            <div className="thinkHR_user">
              <a href="javascript:void(0)" onClick={this.onClickButton} className="primary-button">Get Data</a>
              <a href="javascript:void(0)" className="primary-link">ThinkHR Two-Legged SSO</a>
            </div>
          </div>
        </div>
      </div>
    );
  }

  renderUserInfo() {
    if (this.props.userName) {
      return (
        <div className="sso-user-info">
          <div className="sso-user-type">
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
          <div className="sso-user-type-value">
            <div>
              {this.props.userName}
            </div>
            <div>
              {this.props.userRole}
            </div>
            <div>
              {this.props.userPermission}
            </div>
          </div>
        </div>
      );
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
          {this.renderUserInfo()}
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
        {this.renderUserInfo()}
      </section>
    );
  }
}

UserInfo.propTypes = {
  isLoading: PropTypes.bool,
  error: PropTypes.object,
  userRole: PropTypes.string,
  userName: PropTypes.string,
  userPermission: PropTypes.string,
};

UserInfo.defaultProps = {
  isLoading: false,
  error: null,
  userRole: null,
  userName: null,
  userPermission: null,
};

const mapStateToProps = state => ({
  isLoading: isFetchTokenLoading(state),
  accessToken: getAccessToken(state),
  error: getFetchTokenError(state),
  sendAuthRequest: shouldSendAuthRequest(state),
  userName: userName(state),
  userRole: userRole(state),
  userPermission: userPermission(state),
  ssoUrl: getSsoUrl(state),
});

export default connect(
  mapStateToProps,
)(UserInfo);
