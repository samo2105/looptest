import type { ButtonHTMLAttributes, ReactNode } from 'react';
import clsx from 'clsx';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: ReactNode;
  variant?: 'primary' | 'secondary';
  isLoading?: boolean;
}

export const Button = ({ 
  children, 
  variant = 'primary', 
  isLoading = false,
  className,
  disabled,
  ...props 
}: ButtonProps) => {
  return (
    <button
      className={clsx(
        'px-6 py-2.5 rounded-lg font-medium transition-colors text-base',
        'focus:outline-none focus:ring-2 focus:ring-offset-2',
        variant === 'primary' && [
          'bg-gray-400 text-white',
          'hover:bg-gray-500',
          'focus:ring-gray-400',
          'disabled:bg-gray-300 disabled:cursor-not-allowed disabled:text-gray-500',
          'disabled:hover:bg-gray-300',
        ],
        variant === 'secondary' && [
          'bg-gray-200 text-gray-800',
          'hover:bg-gray-300',
          'focus:ring-gray-500',
        ],
        // Allow className to override default styles (for black button when valid)
        className
      )}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? 'Loading...' : children}
    </button>
  );
};

