import { GET } from './HTTP';
import { getAccessToken } from '../utils/CookieUtils';

export const fetchCompanies = () => {
  const headers = {
    Authorization: `Bearer ${getAccessToken()}`,
  };
  const url = `${baseUrl}v1/companies?sort=-companyName`;
  return GET({ url, headers });
};

