import { useQuery } from '@tanstack/react-query';
import api from '../lib/api';

interface Country {
  code: string;
  name: string;
  official: string;
}

interface CountriesResponse {
  countries: Country[];
}

export const useCountries = () => {
  return useQuery<Country[]>({
    queryKey: ['countries'],
    queryFn: async () => {
      const response = await api.get<CountriesResponse>('/api/v1/countries');
      return response.data.countries;
    },
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};


