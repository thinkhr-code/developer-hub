import { GET } from './HTTP';
import { getAccessToken } from '../utils/CookieUtils';

export const fetchAlerts = () => {
  const headers = {
    Authorization: `Bearer ${getAccessToken()}`,
  };
  const url = `${baseUrl}v1/lawalerts?jurisdiction=MI&jurisdiction=AZ&jurisdiction=FE&startMonth=2016-01&endMonth=2016-12&limit=5`;
  return GET({ url, headers });
};

