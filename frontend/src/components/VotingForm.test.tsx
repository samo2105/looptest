import { describe, it, expect } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { ReactElement } from 'react';
import { VotingForm } from './VotingForm';
import { server } from '../mocks/server';
import { http, HttpResponse } from 'msw';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000';

const createTestQueryClient = () =>
  new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
      mutations: {
        retry: false,
      },
    },
  });

const renderWithProviders = (ui: ReactElement) => {
  const queryClient = createTestQueryClient();
  return render(
    <QueryClientProvider client={queryClient}>{ui}</QueryClientProvider>
  );
};

describe('VotingForm', () => {

  describe('form rendering', () => {
    it('should render all form fields', () => {
      renderWithProviders(<VotingForm />);

      expect(screen.getByPlaceholderText('John')).toBeInTheDocument();
      expect(screen.getByPlaceholderText('johndoe@gmail.com')).toBeInTheDocument();
      expect(document.querySelector('select')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /submit vote/i })).toBeInTheDocument();
    });
  });

  describe('form validation', () => {
    it('should show validation errors on invalid input', async () => {
      renderWithProviders(<VotingForm />);

      const user = userEvent.setup();
      
      // Interact with a field to trigger validation, then clear it
      const nameInput = screen.getByPlaceholderText('John');
      await user.click(nameInput);
      await user.clear(nameInput);
      
      // Try to submit (button might be disabled, but form validation should still run)
      const submitButton = screen.getByRole('button', { name: /submit vote/i });
      if (!submitButton.hasAttribute('disabled')) {
        await user.click(submitButton);
      } else {
        // If button is disabled, trigger form submission programmatically
        const form = submitButton.closest('form');
        if (form) {
          form.requestSubmit();
        }
      }

      await waitFor(() => {
        expect(screen.getByText(/name is required/i)).toBeInTheDocument();
        expect(screen.getByText(/email is required/i)).toBeInTheDocument();
        expect(screen.getByText(/country is required/i)).toBeInTheDocument();
      }, { timeout: 3000 });
    });

    it('should show error for name shorter than 2 characters', async () => {
      renderWithProviders(<VotingForm />);

      const user = userEvent.setup();
      const nameInput = screen.getByPlaceholderText('John');

      await user.type(nameInput, 'J');
      await user.click(screen.getByRole('button', { name: /submit vote/i }));

      await waitFor(() => {
        expect(screen.getByText(/name must be at least 2 characters/i)).toBeInTheDocument();
      });
    });
  });

  describe('successful submission', () => {
    it('should call API and show success notification on successful submission', async () => {
      const mockSuccessHandler = http.post(`${API_URL}/api/v1/votes`, () => {
        return HttpResponse.json(
          {
            vote: {
              id: 1,
              country_code: 'USA',
              created_at: new Date().toISOString(),
            },
            user: {
              id: 1,
              name: 'John Doe',
              email: 'john@example.com',
            },
          },
          { status: 201 }
        );
      });

      server.use(mockSuccessHandler);

      renderWithProviders(<VotingForm />);

      const user = userEvent.setup();

      // Wait for countries to load
      await waitFor(() => {
        const select = document.querySelector('select') as HTMLSelectElement;
        expect(select).not.toBeDisabled();
      }, { timeout: 3000 });

      await user.type(screen.getByPlaceholderText('John'), 'John Doe');
      await user.type(screen.getByPlaceholderText('johndoe@gmail.com'), 'john@example.com');

      const countrySelect = document.querySelector('select') as HTMLSelectElement;
      await user.selectOptions(countrySelect, 'USA');

      const submitButton = screen.getByRole('button', { name: /submit vote/i });
      await user.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Your vote was successfully submitted')).toBeInTheDocument();
      });
    });

    it('should reset form after successful submission', async () => {
      const mockSuccessHandler = http.post(`${API_URL}/api/v1/votes`, () => {
        return HttpResponse.json(
          {
            vote: {
              id: 1,
              country_code: 'USA',
              created_at: new Date().toISOString(),
            },
            user: {
              id: 1,
              name: 'John Doe',
              email: 'john@example.com',
            },
          },
          { status: 201 }
        );
      });

      server.use(mockSuccessHandler);

      renderWithProviders(<VotingForm />);

      const user = userEvent.setup();

      // Wait for countries to load
      await waitFor(() => {
        const select = document.querySelector('select') as HTMLSelectElement;
        expect(select).not.toBeDisabled();
      }, { timeout: 3000 });

      const nameInput = screen.getByPlaceholderText('John') as HTMLInputElement;
      const emailInput = screen.getByPlaceholderText('johndoe@gmail.com') as HTMLInputElement;

      await user.type(nameInput, 'John Doe');
      await user.type(emailInput, 'john@example.com');

      const countrySelect = document.querySelector('select') as HTMLSelectElement;
      await user.selectOptions(countrySelect, 'USA');

      const submitButton = screen.getByRole('button', { name: /submit vote/i });
      await user.click(submitButton);

      await waitFor(() => {
        expect(nameInput.value).toBe('');
        expect(emailInput.value).toBe('');
      });
    });
  });

  describe('409 error handling', () => {
    it('should show duplicate email message on 409 error', async () => {
      const mockConflictHandler = http.post(`${API_URL}/api/v1/votes`, () => {
        return HttpResponse.json(
          { error: 'User has already voted' },
          { status: 409 }
        );
      });

      server.use(mockConflictHandler);

      renderWithProviders(<VotingForm />);

      const user = userEvent.setup();

      // Wait for countries to load
      await waitFor(() => {
        const select = document.querySelector('select') as HTMLSelectElement;
        expect(select).not.toBeDisabled();
      }, { timeout: 3000 });

      await user.type(screen.getByPlaceholderText('John'), 'John Doe');
      await user.type(screen.getByPlaceholderText('johndoe@gmail.com'), 'duplicate@example.com');

      const countrySelect = document.querySelector('select') as HTMLSelectElement;
      await user.selectOptions(countrySelect, 'USA');

      const submitButton = screen.getByRole('button', { name: /submit vote/i });
      await user.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('You have already voted')).toBeInTheDocument();
      });
    });
  });
});
