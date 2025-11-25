import type { InputHTMLAttributes } from 'react';
import { forwardRef } from 'react';
import clsx from 'clsx';

interface SearchInputProps extends InputHTMLAttributes<HTMLInputElement> {
  error?: string;
}

export const SearchInput = forwardRef<HTMLInputElement, SearchInputProps>(
  ({ error, className, ...props }, ref) => {
    return (
      <div className="relative">
        <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
          <svg
            className="h-5 w-5 text-text-secondary"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
        </div>
        <input
          ref={ref}
          type="search"
          className={clsx(
            'w-full pl-10 pr-4 py-2.5 rounded-lg border border-border-grey',
            'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent',
            'text-base text-text-primary placeholder:text-text-secondary bg-white',
            error && 'border-red-500 focus:ring-red-500',
            className
          )}
          aria-invalid={error ? 'true' : 'false'}
          aria-describedby={error ? `${props.id}-error` : undefined}
          {...props}
        />
        {error && (
          <span
            id={props.id ? `${props.id}-error` : undefined}
            className="mt-1 text-sm text-red-600"
            role="alert"
          >
            {error}
          </span>
        )}
      </div>
    );
  }
);

SearchInput.displayName = 'SearchInput';

