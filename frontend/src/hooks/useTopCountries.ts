import { useQuery } from '@tanstack/react-query';
import api from '../lib/api';

interface TopCountry {
  country_code: string;
  vote_count: number;
  name: string | null;
  official: string | null;
  capital: string | null;
  region: string | null;
  subregion: string | null;
}

interface TopCountriesResponse {
  countries: TopCountry[];
}

export const useTopCountries = (limit: number = 10, search?: string) => {
  return useQuery<TopCountry[]>({
    queryKey: ['topCountries', limit, search],
    queryFn: async () => {
      const params = new URLSearchParams();
      params.append('limit', limit.toString());
      if (search) {
        params.append('search', search);
      }
      const response = await api.get<TopCountriesResponse>(
        `/api/v1/countries/top?${params.toString()}`
      );
      return response.data.countries;
    },
    staleTime: 30 * 1000, // 30 seconds
  });
};

