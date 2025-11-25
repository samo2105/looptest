import type { SelectHTMLAttributes } from 'react';
import { forwardRef } from 'react';
import clsx from 'clsx';

interface SelectProps extends Omit<SelectHTMLAttributes<HTMLSelectElement>, 'placeholder'> {
  label?: string;
  error?: string;
  options: Array<{ value: string; label: string }>;
  placeholder?: string;
}

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ label, error, options, placeholder, className, ...props }, ref) => {
    return (
      <div className="flex flex-col w-full relative">
        {label && (
          <label className="text-sm font-medium text-text-primary mb-1">
            {label}
          </label>
        )}
        <div className="relative">
          <select
            ref={ref}
            className={clsx(
              'px-4 py-2.5 rounded-lg border border-border-grey w-full',
              'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent',
              'text-base text-text-primary bg-white appearance-none pr-10',
              error && 'border-red-500 focus:ring-red-500',
              className
            )}
            aria-invalid={error ? 'true' : 'false'}
            aria-describedby={error ? `${props.id}-error` : undefined}
            {...props}
          >
            <option value="">{placeholder || 'Select...'}</option>
            {options.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
          <div className="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
            <svg
              className="h-5 w-5 text-text-secondary"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M19 9l-7 7-7-7"
              />
            </svg>
          </div>
        </div>
        {/* Error message container with fixed height to prevent layout shift */}
        <div className="h-5 mt-1">
          {error && (
            <span
              id={props.id ? `${props.id}-error` : undefined}
              className="text-sm text-red-600"
              role="alert"
            >
              {error}
            </span>
          )}
        </div>
      </div>
    );
  }
);

Select.displayName = 'Select';

