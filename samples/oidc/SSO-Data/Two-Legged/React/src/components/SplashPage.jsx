/* eslint-disable no-script-url */
import React, { Component } from 'react';
import { connect } from 'react-redux';
import Alerts from './Alerts';
import Companies from './Companies';
import Users from './Users';
import { getClientId, getQueryString, getReturnURL } from '../utils/CommonUtils';
import { logoutAction } from '../actions';
import UserInfo from './UserInfo';
import Popup from './UserSelect';
import thinkhrLogo from '../images/thinkHR.png';
import { getAuthProvider } from '../utils/CookieUtils';

class SplashPage extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showPopup: false,
    };
  }

  togglePopup() {
    this.setState({
      showPopup: !this.state.showPopup,
    });
  }

  render() {
    return (
      <div className="thinkHR-widget" id="badge">
        <header>
          <div className="logo">
            <a href="javascript:void(0)" className="thinkhr-logo">
              <img src={thinkhrLogo} />
            </a>
          </div>
          <div className="heart" />
          <div className="header-title">OIDC SSO to APIs Demo Widget</div>
          <a className="logout" href="javascript:void(0)" onClick={this.props.logout}>Logout
          </a>
        </header>
        {<UserInfo onUserSelect={this.togglePopup.bind(this)} />}
        {this.state.showPopup ? <Popup closePopup={this.togglePopup.bind(this)} /> : null }
        {<Companies />}
        {<Users />}
        {<Alerts />}
      </div>
    );
  }
}

const mapDispatchToProps = (dispatch, ownProps) => ({
  logout: () => dispatch(logoutAction()),
});

export default connect(
  null, mapDispatchToProps,
)(SplashPage);
