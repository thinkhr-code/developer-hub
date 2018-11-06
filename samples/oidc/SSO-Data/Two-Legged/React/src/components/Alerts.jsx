/* eslint-disable no-script-url */
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import DataGrid from './DataGrid';
import { fetchAlertsAction, fetchTokenSuccess } from './../actions';
import { selectors } from './../reducers/alertReducer';
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
const { isFetchAlertsLoading, getFetchAlertsError, getAlerts } = selectors;

class Alerts extends Component {
  constructor(props) {
    super(props);
  }

  componentWillMount() {
    if (this.props.accessToken) {
      this.props.fetchAlertsAction();
    }
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.accessToken && (this.props.accessToken !== nextProps.accessToken)) {
      nextProps.fetchAlertsAction();
    }
    if (!this.props.sendAuthRequest && nextProps.sendAuthRequest) {
        this.props.onUserSelect();
    }
  }

  getAlertsData() {

    return (this.props.alerts) ? (this.props.alerts) : null;
  }

  gridHeaderData() {
    return [
      {
        'name': 'TITLE',
        'key': 'title',
      },
      {
        'name': 'JURISDICTION',
        'key': 'jurisdiction',
      },
      {
        'name': 'PUBLICATION DATE',
        'key': 'publicationDate',
      },
      {
        'name': 'PUBLICATION',
        'key': 'publication',
      },
    ];
  }

  onClickButton() {
    setAuthProvider('sso');
    if (this.props.accessToken) {
      this.props.fetchAlertsAction();
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
        <DataGrid typeName={"LAW ALERT "} data={this.getAlertsData()} metadata={this.gridHeaderData()} />
      </section>
    );
  }
}

Alerts.propTypes = {
  isLoading: PropTypes.bool,
  alerts: PropTypes.array,
  fetchAlertsAction: PropTypes.func,
  error: PropTypes.object,
  userRole: PropTypes.string,
  userName: PropTypes.string,
  userPermission: PropTypes.string,
};

Alerts.defaultProps = {
  isLoading: false,
  alerts: [],
  fetchAlertsAction: () => {
  },
  error: null,
  userRole: null,
  userName: null,
  userPermission: null,
};

const mapStateToProps = state => ({
  isLoading: isFetchAlertsLoading(state),
  alerts: getAlerts(state),
  accessToken: getAccessToken(state),
  error: getFetchAlertsError(state),
  sendAuthRequest: shouldSendAuthRequest(state),
  userName: userName(state),
  userRole: userRole(state),
  userPermission: userPermission(state),
  ssoUrl: getSsoUrl(state),
});

const mapDispatchToProps = dispatch => ({
  fetchAlertsAction: () => dispatch(fetchAlertsAction()),
  fetchTokenSuccessAction: () => dispatch(fetchTokenSuccess('testToken')),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(Alerts);
