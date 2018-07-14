import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchAccessTokenAction } from './../actions';
import thinkhrLogo from '../images/thinkHR.png';

class Popup extends Component {
  constructor(props) {
    super(props);
    this.onClickUser1Button = this.onClickUser1Button.bind(this);
    this.onClickUser2Button = this.onClickUser2Button.bind(this);
    this.onClickUser3Button = this.onClickUser3Button.bind(this);

  }


  // Change the button actions and render information to match the broker account you are using.
  // e.g. replace Adam Smith (adam.smith.sso@test.com) with a Broker Admin from your own Broker Account.
  //      replace Walter Smith (walter.smith.sso@test.com) with a Broker from your own Broker Account.
  //      replace Raphael Smith (raphael.smith.sso@test.com) with a Student from your own Broker Account.
  onClickUser1Button() {
    const userData = {
      'user': 'Adam Smith',
      'role': 'Broker Admin',
      'permission': ' List all companies and users under the broker including self.',
    };
    this.props.fetchAccessToken("adam.smith.sso@test.com", userData);
    this.props.closePopup();
  }

  onClickUser2Button() {
    const userData = {
      'user': 'Walter  Smith',
      'role': 'RE Admin',
      'permission': ' List own company and users.',
    };

    this.props.fetchAccessToken("walter.smith.sso@test.com", userData);
    this.props.closePopup();
  }

  onClickUser3Button() {
    const userData = {
      'user': 'Raphael  Smith',
      'role': 'Student',
      'permission': 'No access to APIs',
    };
    this.props.fetchAccessToken("raphael.smith.sso@test.com", userData);
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
  fetchAccessToken: (mappedValue, userData) => dispatch(fetchAccessTokenAction(mappedValue, userData)),
});

export default connect(
  null, mapDispatchToProps,
)(Popup);
