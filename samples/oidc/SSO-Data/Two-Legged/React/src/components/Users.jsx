/* eslint-disable no-script-url */
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import DataGrid from './DataGrid';
import { fetchUsersAction, fetchTokenSuccess } from './../actions';
import { selectors } from './../reducers/userReducer';
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
const { isFetchUsersLoading, getFetchUsersError, getUsers } = selectors;

class Users extends Component {
  constructor(props) {
    super(props);
  }

  componentWillMount() {
    if (this.props.accessToken) {
      this.props.fetchUsersAction();
    }
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.accessToken && (this.props.accessToken !== nextProps.accessToken)) {
      nextProps.fetchUsersAction();
    }
    if (!this.props.sendAuthRequest && nextProps.sendAuthRequest) {
        this.props.onUserSelect();
    }
  }

  getUsersData() {
    return (this.props.users) ? (this.props.users) : null;
  }

  gridHeaderData() {
    return [
      {
        'name': 'ID',
        'key': 'userId',
      },
      {
        'name': 'FIRST NAME',
        'key': 'firstName',
      },
      {
        'name': 'LAST NAME',
        'key': 'lastName',
      },
      {
        'name': 'USERNAME',
        'key': 'userName',
      },
      {
        'name': 'EMAIL',
        'key': 'email',
      },
      {
        'name': 'ROLE',
        'key': 'role',
      },
    ];
  }

  onClickButton() {
    setAuthProvider('sso');
    if (this.props.accessToken) {
      this.props.fetchUsersAction();
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
        <DataGrid typeName={"USER "} data={this.getUsersData()} metadata={this.gridHeaderData()} />
      </section>
    );
  }
}

Users.propTypes = {
  isLoading: PropTypes.bool,
  users: PropTypes.array,
  fetchUsersAction: PropTypes.func,
  error: PropTypes.object,
  userRole: PropTypes.string,
  userName: PropTypes.string,
  userPermission: PropTypes.string,
};

Users.defaultProps = {
  isLoading: false,
  users: [],
  fetchUsersAction: () => {
  },
  error: null,
  userRole: null,
  userName: null,
  userPermission: null,
};

const mapStateToProps = state => ({
  isLoading: isFetchUsersLoading(state),
  users: getUsers(state),
  accessToken: getAccessToken(state),
  error: getFetchUsersError(state),
  sendAuthRequest: shouldSendAuthRequest(state),
  userName: userName(state),
  userRole: userRole(state),
  userPermission: userPermission(state),
  ssoUrl: getSsoUrl(state),
});

const mapDispatchToProps = dispatch => ({
  fetchUsersAction: () => dispatch(fetchUsersAction()),
  fetchTokenSuccessAction: () => dispatch(fetchTokenSuccess('testToken')),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(Users);
