import type { InputHTMLAttributes } from 'react';
import { forwardRef } from 'react';
import clsx from 'clsx';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, className, ...props }, ref) => {
    return (
      <div className="flex flex-col w-full relative">
        {label && (
          <label className="text-sm font-medium text-text-primary mb-1.5">
            {label}
          </label>
        )}
        <div className="relative">
          <input
            ref={ref}
            className={clsx(
              'px-4 py-2.5 rounded-lg border border-border-grey',
              'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent',
              'text-base text-text-primary placeholder:text-text-secondary bg-white',
              error && 'border-red-500 focus:ring-red-500',
              className
            )}
            aria-invalid={error ? 'true' : 'false'}
            aria-describedby={error ? `${props.id}-error` : undefined}
            {...props}
          />
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

Input.displayName = 'Input';

