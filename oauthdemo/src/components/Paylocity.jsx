import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchPaylocityAccessTokenAction } from '../actions';
import thinkhrLogo from './../images/thinkHR.png';

class Popup extends Component {
  constructor(props) {
    super(props);
    this.onClickUser1Button = this.onClickUser1Button.bind(this);
    this.onClickUser2Button = this.onClickUser2Button.bind(this);
    this.onClickUser3Button = this.onClickUser3Button.bind(this);

  }


  onClickUser1Button() {
    const userData = {
      'user': 'Adam Smith',
      'role': 'Broker Admin',
      'permission': ' List all companies under the broker including self.',
    };
    this.props.fetchPaylocityAccessToken("adam.smith.sso@paylocityTest.com", userData);
    this.props.closePopup();
  }

  onClickUser2Button() {
    const userData = {
      'user': 'Walter  Smith',
      'role': 'RE Admin',
      'permission': ' List own company.',
    };

    this.props.fetchPaylocityAccessToken("walter.smith.sso@paylocityTest.com", userData);
    this.props.closePopup();
  }

  onClickUser3Button() {
    const userData = {
      'user': 'Raphael  Smith',
      'role': 'RE',
      'permission': 'No access to List Companies API',
    };
    this.props.fetchPaylocityAccessToken("raphael.smith.sso@paylocityTest.com", userData);
    this.props.closePopup();
  }

  render() {
    return (
      <div id="popup1" className="overlay">
        <div className="popup">
          <div className="logo-image">
            <img src={thinkhrLogo} />
          </div>
          <hr />
          <a className="close" href="#" onClick={this.props.closePopup}>&times;</a>
          <div className="popup-content">
            <div>
              <span>Adam Smith</span>
              <span>
                <button onClick={this.onClickUser1Button}>Sign in</button>
              </span>
            </div>
            <div>
              <span>Walter Smith</span>
              <span>
                <button onClick={this.onClickUser2Button}>Sign in</button>
              </span>
            </div>
            <div>
              <span>Raphael Smith</span>
              <span>
                <button onClick={this.onClickUser3Button}>Sign in</button>
              </span>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

const mapDispatchToProps = dispatch => ({
  fetchPaylocityAccessToken: (mappedValue, userData) => dispatch(fetchPaylocityAccessTokenAction(mappedValue, userData)),
});

export default connect(
  null, mapDispatchToProps,
)(Popup);