import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import clsx from 'clsx';
import { voteSchema, type VoteFormData } from '../schemas/voteSchema';
import { Input } from './ui/Input';
import { Select } from './ui/Select';
import { Button } from './ui/Button';
import api, { type ApiError } from '../lib/api';
import { useCountries } from '../hooks/useCountries';

interface VoteResponse {
  vote: {
    id: number;
    country_code: string;
    created_at: string;
  };
  user: {
    id: number;
    name: string;
    email: string;
  };
}

export const VotingForm = () => {
  const queryClient = useQueryClient();
  const { data: countries = [], isLoading: countriesLoading } = useCountries();
  const [notification, setNotification] = useState<{
    type: 'success' | 'error';
    message: string;
  } | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting, isValid },
    reset,
  } = useForm<VoteFormData>({
    resolver: zodResolver(voteSchema),
    mode: 'all', // Validate on both change and submit for real-time feedback and submit-time errors
  });

  // Clear notification after 4 seconds
  useEffect(() => {
    if (notification) {
      const timer = setTimeout(() => {
        setNotification(null);
      }, 4000);
      return () => clearTimeout(timer);
    }
  }, [notification]);

  const voteMutation = useMutation<VoteResponse, ApiError, VoteFormData>({
    mutationFn: async (data) => {
      const response = await api.post<VoteResponse>('/api/v1/votes', {
        vote: data,
      });
      return response.data;
    },
    onSuccess: () => {
      setNotification({
        type: 'success',
        message: 'Your vote was successfully submitted',
      });
      reset();
      // Invalidate and refetch top countries
      queryClient.invalidateQueries({ queryKey: ['topCountries'] });
    },
    onError: (error) => {
      if (error.status === 409) {
        setNotification({
          type: 'error',
          message: 'You have already voted',
        });
      } else {
        setNotification({
          type: 'error',
          message: error.message || 'Failed to submit vote',
        });
      }
    },
  });

  const onSubmit = (data: VoteFormData) => {
    voteMutation.mutate(data);
  };

  const countryOptions = countries.map((country) => ({
    value: country.code,
    label: country.name,
  }));

  return (
    <section className="mb-6 sm:mb-8">
      <div className="bg-white border border-border-grey rounded-3xl">
        {notification ? (
          /* Notification replaces the form */
          <div className="flex items-center gap-3 p-4">
            {notification.type === 'success' ? (
              <div className="flex-shrink-0 w-6 h-6 bg-green-500 rounded-full flex items-center justify-center">
                <svg
                  className="w-4 h-4 text-white"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M5 13l4 4L19 7"
                  />
                </svg>
              </div>
            ) : (
              <div className="flex-shrink-0 w-6 h-6 bg-red-500 rounded-full flex items-center justify-center">
                <svg
                  className="w-4 h-4 text-white"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </div>
            )}
            <p className="text-xl font-bold text-text-primary">
              {notification.message}
            </p>
          </div>
        ) : (
          /* Form content */
          <div className="pb-8 pt-4 px-4">
            <form onSubmit={handleSubmit(onSubmit)}>
              <p className="text-sm font-semibold text-text-primary mb-3">
                Vote your Favourite Country
              </p>

              <div className="flex flex-col md:flex-row gap-3 md:items-start">
                {/* Name Input */}
                <div className="flex-1 w-full">
                  <Input
                    {...register('name')}
                    placeholder="John"
                    error={errors.name?.message}
                    className="w-full h-10"
                  />
                </div>

                {/* Email Input */}
                <div className="flex-1 w-full">
                  <Input
                    {...register('email')}
                    type="email"
                    placeholder="johndoe@gmail.com"
                    error={errors.email?.message}
                    className="w-full h-10"
                  />
                </div>

                {/* Country Select */}
                <div className="flex-1 w-full">
                  <Select
                    {...register('country_code')}
                    placeholder="Country"
                    options={countryOptions}
                    error={errors.country_code?.message}
                    disabled={countriesLoading}
                    className="w-full h-10"
                  />
                </div>

                {/* Submit Button */}
                <div className="flex-shrink-0 w-full md:w-auto flex flex-col">
                  <Button
                    type="submit"
                    isLoading={isSubmitting}
                    disabled={!isValid || isSubmitting || countriesLoading}
                    className={clsx(
                      'whitespace-nowrap w-full md:w-auto',
                      isValid && !isSubmitting && !countriesLoading
                        ? 'bg-black text-white hover:bg-gray-900'
                        : ''
                    )}
                  >
                    {isSubmitting ? 'Vote Submitted' : 'Submit Vote'}
                  </Button>
                  {/* Spacer to match error message height for alignment */}
                  <div className="h-5 mt-1"></div>
                </div>
              </div>
            </form>
          </div>

        )}
      </div>
    </section>
  );
};

