/**
 * Set a cookie in the browser
 *
 * @param  {String}  name            Name of the cookie
 * @param  {String}  value           Value of the cookie
 * @param  {Object}  options         Set of options passed in
 * @param  {Number}  options.days    Duration of the cookie
 * @param  {String}  options.path    Path of the cookie
 * @param  {Boolean} options.encode  Should the cookie be encoded?
 */
export function setCookie(name, value, options = { days: 1, path: '/', encode: true, }) {
  const currentDate = new Date();
  // Calculate and set the correct expire time
  currentDate.setTime(currentDate.getTime() + (options.days * 864e5));
  // Define the expires parameter of the cookie
  const expires = `expires=${currentDate.toUTCString()}`;
  // Define the path parameter of the cookie
  const path = `path=${options.path}`;
  // Build the new cookie's name & value parameter
  let nameAndValue = `${name}=${value}`;

  if (options.encode) {
    nameAndValue = `${name}=${encodeURIComponent(value)}`;
  }

  document.cookie = `${nameAndValue}; ${expires}; ${path}`;
}

/**
 * Get a cookie from the browser
 *
 * @param  {String}  name            Name of the cookie
 * @param  {Object}  options         The set of options passed in
 * @param  {Boolean} options.decode  Should the cookie be decoded?
 * @return {String}                  Value of the requested cookie
 */
export function getCookie(name, options = { decode: true, }) {
  const docCookie = document.cookie;
  if (docCookie.length > 0) {
    return docCookie.split('; ').reduce((theRef, theCookie) => {
      // Split the cookie into a name + value pair at the '=' string operator
      const parts = theCookie.split(/=(.+)/);
      // Assign a new cookie value if the name and first item in the parts list is a match
      let cookieValue = parts[0] === name ? parts[1] : theRef;
      // If the decode flag has been passed in via the options,
      // then decode the returned cookie value.
      if (options.decode) {
        cookieValue = decodeURIComponent(cookieValue);
      }

      return cookieValue;
    }, '');
  }
  return '';
}

/**
 * Delete a cookie from the browser
 *
 * @param  {String} name Name of the cookie to be deleted
 */
export function deleteCookie(name) {
  setCookie(name, '', {
    days: -1,
    path: '/',
  });
}

export function getAccessToken() {
  return getCookie('THINKHR_ACCESS_TOKEN', { decode: false });
}

export function setAccessToken(token) {
  setCookie('THINKHR_ACCESS_TOKEN', token);
}

export function getRefreshToken() {
  return getCookie('THINKHR_REFRESH_TOKEN', { decode: false });
}

export function setRefreshToken(token) {
  setCookie('THINKHR_REFRESH_TOKEN', token);
}

export function getAuthProvider() {
  return getCookie('AUTH_PROVIDER', { decode: false });
}

export function setAuthProvider(provider) {
  setCookie('AUTH_PROVIDER', provider);
}
