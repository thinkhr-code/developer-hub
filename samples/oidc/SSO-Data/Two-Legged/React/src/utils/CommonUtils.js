// TODO: Define this
const REDIRECT_URL = 'localhost';

/**
 * Get the value of a querystring
 *
 * @param  {String} query The query to get the value of
 * @param  {String} url   The URL to get the value from (optional)
 * @return {String}       The query value
 */
export const getQueryString = (query, url) => {
  let href = window.location.href;
  if (url) {
    href = url;
  }
  const reg = new RegExp(`[?&]${query}=([^&#]*)`, 'i');
  const string = reg.exec(href);
  return string ? string[1] : null;
};


export const getReturnURL = () => {
  const url = `${window.location.href}`;
  const arr = url.split("#");
  return arr[0];
};

export const getAuthorizationHeader = () => {
  const Base64 = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
  return Base64;
};

export const getClientId = () => clientId;

export const getClientSecret = () => clientSecret;

export const submitAuthForm = () => {
  document.getElementById('clientsForm').submit();
};
