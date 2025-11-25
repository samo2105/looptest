import { useState } from 'react';
import { useTopCountries } from '../hooks/useTopCountries';
import { SearchInput } from './ui/SearchInput';
import { Table } from './ui/Table';
import { useDebounce } from '../hooks/useDebounce';

export const LeaderboardTable = () => {
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 300);
  const { data: countries = [], isLoading } = useTopCountries(10, debouncedSearch);

  const columns = [
    {
      header: 'Country',
      accessor: 'name',
      render: (value: string | null, row: any) => value || row.country_code,
    },
    {
      header: 'Capital City',
      accessor: 'capital',
      render: (value: string | null) => value || '-',
    },
    {
      header: 'Region',
      accessor: 'region',
      render: (value: string | null) => value || '-',
    },
    {
      header: 'Sub Region',
      accessor: 'subregion',
      render: (value: string | null) => value || '-',
    },
    {
      header: 'Votes',
      accessor: 'vote_count',
      render: (value: number) => value.toString(),
    },
  ];

  return (
    <section>
      <h2 className="text-3xl font-bold text-text-primary mb-3">
        Top 10 Most Voted Countries
      </h2>
      
      <div className="mb-4 xl:w-1/3">
        <SearchInput
          placeholder="Search Country, Capital City, Region or Subregion"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="text-sm"
        />
      </div>

      <div className="bg-white rounded-3xl border border-border-grey overflow-hidden">
        <Table
          columns={columns}
          data={countries}
          isLoading={isLoading}
          emptyMessage="No countries found. Be the first to vote!"
        />
      </div>
    </section>
  );
};

