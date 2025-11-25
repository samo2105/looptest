import { z } from 'zod';

export const voteSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, 'Name is required')
    .min(2, 'Name must be at least 2 characters'),
  email: z
    .string()
    .trim()
    .min(1, 'Email is required')
    .email('Invalid email format'),
  country_code: z
    .string()
    .trim()
    .min(1, 'Country is required'),
});

export type VoteFormData = z.infer<typeof voteSchema>;

