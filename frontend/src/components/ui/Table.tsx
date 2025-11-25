import type { ReactNode } from 'react';
import clsx from 'clsx';

interface TableColumn {
  header: string;
  accessor: string;
  render?: (value: any, row: any) => ReactNode;
  className?: string;
}

interface TableProps {
  columns: TableColumn[];
  data: any[];
  isLoading?: boolean;
  emptyMessage?: string;
}

export const Table = ({ columns, data, isLoading = false, emptyMessage = 'No data available' }: TableProps) => {
  if (isLoading) {
    return (
      <div className="w-full">
        <div className="animate-pulse space-y-4">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="h-12 bg-gray-200 rounded"></div>
          ))}
        </div>
      </div>
    );
  }

  if (data.length === 0) {
    return (
      <div className="w-full text-center py-12 text-text-secondary">
        {emptyMessage}
      </div>
    );
  }

  return (
    <div className="w-full overflow-x-auto">
      <table className="w-full border-collapse">
        <thead>
          <tr className="bg-white">
            {columns.map((column, index) => (
              <th
                key={column.accessor}
                className={clsx(
                  'px-4 py-3 text-sm font-bold text-text-primary text-left',
                  index === columns.length - 1 ? 'xl:w-12' : '',
                  column.className
                )}
                scope="col"
              >
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, rowIndex) => (
            <tr
              key={rowIndex}
              className="bg-white"
            >
              {columns.map((column, colIndex) => (
                <td
                  key={column.accessor}
                  className={clsx(
                    'px-4 py-3 text-sm text-text-primary text-left',
                    colIndex === columns.length - 1 ? 'xl:w-12 whitespace-nowrap' : '',
                    column.className
                  )}
                >
                  {column.render
                    ? column.render(row[column.accessor], row)
                    : row[column.accessor]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

