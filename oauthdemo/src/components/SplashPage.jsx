/* eslint-disable no-script-url */
import React, { Component } from 'react';
import { connect } from 'react-redux';
import Companies from './Companies';
import { getClientId, getQueryString, getReturnURL } from '../utils/CommonUtils';
import { logoutAction, fetchGoogleAccessTokenAction, fetchAccessTokenFromCodeAction } from '../actions';
import Popup from './Paylocity';
import thinkhrLogo from './../images/thinkHR.png';
import { getAuthProvider } from './../utils/CookieUtils';

class SplashPage extends Component {
  constructor(props) {
    super(props);
    this.auth = this.auth.bind(this);
    this.receiveMessage = this.receiveMessage.bind(this);
    window.addEventListener('message', this.receiveMessage, false);
    this.state = {
      showPopup: false,
    };
  }

  componentWillMount() {
    const authCode = getQueryString('code');
    const state = getQueryString('state');
    const error = getQueryString('error');

    if (authCode) {
      if (authCode && state) {
        window.opener.postMessage({ authCode, state }, '*');
        window.close();
      } else {
        window.opener.postMessage({ authCode }, '*');
        window.close();
      }
    }
    if (error) {
      window.close();
    }
  }

  receiveMessage(event) {
    if (event && event.data) {
      if (event.data.authCode && event.data.state === 'google') {
        this.props.fetchGoogleAccessToken(event.data.authCode);
      } else if (event.data.authCode) {
        this.props.fetchAccessTokenFromCodeAction(event.data.authCode);
      }
    }

  }

  auth() {
    function OpenWindowWithPost(url, windowoption, name, params) {
      const form = document.createElement('form');
      form.setAttribute('method', 'GET');
      form.setAttribute('action', url);
      form.setAttribute('target', name);

      for (const i in params) {
        if (Object.prototype.hasOwnProperty.call(params, i)) {
          const input = document.createElement('input');
          input.type = 'hidden';
          input.name = i;
          input.value = params[i];
          form.appendChild(input);
        }
      }

      document.body.appendChild(form);
      // note I am using a post.htm page since I did not want to make double request to the page
      // it might have some Page_Load call which might screw things up.
      window.open('post.htm', name, windowoption);

      form.submit();

      document.body.removeChild(form);

    }

    function NewFile() {
      const param = {
        'response_type': 'code',
        'client_id': getClientId(),
        'redirect_uri': getReturnURL(),
        'scope': 'all',
      };
      OpenWindowWithPost(`${baseUrl}v1/oauth/authorize`,
        'width=730,height=445,left=100,top=100,resizable=yes,scrollbars=yes',
        'NewFile', param);
    }

    NewFile();
  }

  togglePopup() {
    this.setState({
      showPopup: !this.state.showPopup,
    });
  }

  googleAuth() {
    function OpenWindowWithPost(url, windowoption, name, params) {
      const form = document.createElement('form');
      form.setAttribute('method', 'GET');
      form.setAttribute('action', url);
      form.setAttribute('target', name);

      for (const i in params) {
        if (Object.prototype.hasOwnProperty.call(params, i)) {
          const input = document.createElement('input');
          input.type = 'hidden';
          input.name = i;
          input.value = params[i];
          form.appendChild(input);
        }
      }

      document.body.appendChild(form);
      // note I am using a post.htm page since I did not want to make double request to the page
      // it might have some Page_Load call which might screw things up.
      window.open('post.htm', name, windowoption);

      form.submit();

      document.body.removeChild(form);

    }

    function NewFile() {
      const param = {
        'response_type': 'code',
        'client_id': '101163496378-g4rommimqt55a1m6om01aotp2c3tajkj.apps.googleusercontent.com',
        'redirect_uri': getReturnURL(),
        'scope': 'openid profile email phone',
        'state': 'google',
      };
      OpenWindowWithPost('https://accounts.google.com/o/oauth2/auth',
        'width=730,height=445,left=100,top=100,resizable=yes,scrollbars=yes',
        'NewFile', param);
    }

    NewFile();

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
          <div className="header-title">oAuth Demo Widget</div>
          <a className="logout" href="javascript:void(0)" onClick={this.props.logout}>Logout
          </a>
        </header>{<Companies onAuth={this.auth} onPaylocity={this.togglePopup.bind(this)} onGoogleAuth={this.googleAuth} />}
        {this.state.showPopup ? <Popup closePopup={this.togglePopup.bind(this)} /> : null }
      </div>
    );
  }
}

const mapDispatchToProps = (dispatch, ownProps) => ({
  fetchAccessTokenFromCodeAction: code => dispatch(fetchAccessTokenFromCodeAction(code)),
  logout: () => dispatch(logoutAction()),
  fetchGoogleAccessToken: code => dispatch(fetchGoogleAccessTokenAction(code)),
});

export default connect(
  null, mapDispatchToProps,
)(SplashPage);
