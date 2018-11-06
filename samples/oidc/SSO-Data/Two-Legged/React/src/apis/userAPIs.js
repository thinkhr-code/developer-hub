import { GET } from './HTTP';
import { getAccessToken } from '../utils/CookieUtils';

export const fetchUsers = () => {
  const headers = {
    Authorization: `Bearer ${getAccessToken()}`,
  };
  const url = `${baseUrl}v1/users?isActive=1&limit=5`;
  return GET({ url, headers });
};

