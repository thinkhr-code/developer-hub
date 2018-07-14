import { getAccessToken } from '../utils/CookieUtils';

/**
 * Generic Application Headers required for each API call.
 * @type {Object}
 */
const APP_HEADERS = {
  Authorization: `Bearer ${getAccessToken()}`,
  Accept: 'application/json',
  'Content-Type': 'application/json',
};

/**
 * Generic FETCH() method implementation.
 * It returns a promise which has the final JSON after going through the .json() method.
 *
 * @param  {String}  options.url    The URL to fetch from
 * @param  {Object}  options.config The defined config object with method
 *                                  type, headers, mode, body, etc.
 * @return {Promise}
 */
function FETCH({ url, config }) {
  // Added below line to set cookie in response for Gemini APIs
  //config.credentials = 'include';

  return new Promise((resolve, reject) => {
    fetch(url, config)
      .then((resp) => {
        // If the HTTP response is a non 200 status code, attempt to parse the
        // generated error message, otherwise just return the default
        // status message
        if (!resp.ok) {
          resp.json()
            .then(json => reject(json))
            .catch((error) => {
              // Handled the case when API response cannot be prased to JSON.
              const errorMessage = 'Error occurred while processing request.';
              // console.warn(`unable to parse API error message. ERROR: ${error}`);
              reject({ error: {
                message: errorMessage,
              } });
            });

          // Otherwise, the request was successful and we return the
          // parsed JSON response.
        } else {
          resp.json().then(json => resolve(json));
        }
      })

      // Finally, catch any other errors and reject the Promise
      .catch((error) => {
        // Handled the case when API response cannot be prased to JSON.
        const errorMessage = 'Error occurred while processing request.';
        //console.error(`Unable to parse API error message. ERROR: ${error}`);
        reject({ error: {
          message: errorMessage,
        } });
      });
  });
}

/**
 * Simple GET() method.
 * Returns a FETCH() call which returns a promise
 *
 * @param  {String}  options.url     The URL to GET
 * @param  {Object}  options.headers Any additional headers
 * @return {Promise}
 */
export function GET({ url, headers }) {
  const config = {
    method: 'GET',
    headers: Object.assign({}, APP_HEADERS, headers),
    mode: 'cors',
    cache: 'default',
  };

  return FETCH({ url, config });
}

/**
 * Simple POST() method.
 * Returns a FETCH() call which returns a promise
 *
 * @param  {String}  options.url     The URL to POST to
 * @param  {Object}  options.headers Any additional headers
 * @param  {Object}  options.body    The Body of the POST request
 * @return {Promise}
 */
export function formGET({ url, headers, body }) {
  const config = {
    method: 'GET',
    headers,
    body,
    mode: 'cors',
    cache: 'default',
  };

  return FETCH({ url, config });
}

/**
 * Simple POST() method.
 * Returns a FETCH() call which returns a promise
 *
 * @param  {String}  options.url     The URL to POST to
 * @param  {Object}  options.headers Any additional headers
 * @param  {Object}  options.body    The Body of the POST request
 * @return {Promise}
 */
export function POST({ url, headers, body }) {
  const config = {
    method: 'POST',
    headers: Object.assign({}, APP_HEADERS, headers),
    body: JSON.stringify(body),
    mode: 'cors',
    cache: 'default',
  };

  return FETCH({ url, config });
}

/**
 * Simple POST() method.
 * Returns a FETCH() call which returns a promise
 *
 * @param  {String}  options.url     The URL to POST to
 * @param  {Object}  options.headers Any additional headers
 * @param  {Object}  options.body    The Body of the POST request
 * @return {Promise}
 */
export function formPOST({ url, headers, body }) {
  const config = {
    method: 'POST',
    headers,
    body,
    mode: 'cors',
    cache: 'default',
  };

  return FETCH({ url, config });
}

/**
 * Simple PUT() method.
 * Returns a FETCH() call which returns a promise
 *
 * @param  {String}  options.url     The URL to PUT to
 * @param  {Object}  options.headers Any additional headers
 * @param  {Object}  options.body    The Body of the PUT request
 * @return {Promise}
 */
export function PUT({ url, headers, body }) {
  const config = {
    method: 'PUT',
    headers: Object.assign({}, APP_HEADERS, headers),
    body: JSON.stringify(body),
    mode: 'cors',
    cache: 'default',
  };

  return FETCH({ url, config });
}

/**
 * Delete HTTP method
 *
 * @param  {String}  options.url     The URL to PUT to
 * @param  {Object}  options.headers Any additional headers
 * @param  {Object}  options.body    The Body of the PUT request
 * @return {Promise}
 */
export function DELETE({ url, headers, body }) {
  const config = {
    method: 'DELETE',
    headers: Object.assign({}, APP_HEADERS, headers),
    body: JSON.stringify(body),
    mode: 'cors',
    cache: 'default',
  };

  return FETCH({ url, config });
}
