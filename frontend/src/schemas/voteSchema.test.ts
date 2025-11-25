import { describe, it, expect } from 'vitest';
import { voteSchema } from './voteSchema';

describe('voteSchema', () => {
  describe('valid input', () => {
    it('should validate valid input', () => {
      const validData = {
        name: 'John Doe',
        email: 'john@example.com',
        country_code: 'USA',
      };

      const result = voteSchema.safeParse(validData);
      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data).toEqual(validData);
      }
    });

    it('should validate input with minimum name length', () => {
      const validData = {
        name: 'Jo',
        email: 'jo@example.com',
        country_code: 'USA',
      };

      const result = voteSchema.safeParse(validData);
      expect(result.success).toBe(true);
    });
  });

  describe('invalid email', () => {
    it('should reject invalid email format', () => {
      const invalidData = {
        name: 'John Doe',
        email: 'invalid-email',
        country_code: 'USA',
      };

      const result = voteSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues[0].message).toBe('Invalid email format');
      }
    });

    it('should reject email without @ symbol', () => {
      const invalidData = {
        name: 'John Doe',
        email: 'johnexample.com',
        country_code: 'USA',
      };

      const result = voteSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
    });

    it('should reject email without domain', () => {
      const invalidData = {
        name: 'John Doe',
        email: 'john@',
        country_code: 'USA',
      };

      const result = voteSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
    });
  });

  describe('empty name', () => {
    it('should reject empty name', () => {
      const invalidData = {
        name: '',
        email: 'john@example.com',
        country_code: 'USA',
      };

      const result = voteSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        const nameError = result.error.issues.find((issue) => issue.path[0] === 'name');
        expect(nameError?.message).toBe('Name is required');
      }
    });

    it('should reject name with only whitespace', () => {
      const invalidData = {
        name: '   ',
        email: 'john@example.com',
        country_code: 'USA',
      };

      const result = voteSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
    });

    it('should reject name shorter than 2 characters', () => {
      const invalidData = {
        name: 'J',
        email: 'john@example.com',
        country_code: 'USA',
      };

      const result = voteSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        const nameError = result.error.issues.find((issue) => issue.path[0] === 'name');
        expect(nameError?.message).toBe('Name must be at least 2 characters');
      }
    });
  });

  describe('empty country', () => {
    it('should reject empty country_code', () => {
      const invalidData = {
        name: 'John Doe',
        email: 'john@example.com',
        country_code: '',
      };

      const result = voteSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        const countryError = result.error.issues.find((issue) => issue.path[0] === 'country_code');
        expect(countryError?.message).toBe('Country is required');
      }
    });
  });

  describe('empty email', () => {
    it('should reject empty email', () => {
      const invalidData = {
        name: 'John Doe',
        email: '',
        country_code: 'USA',
      };

      const result = voteSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        const emailError = result.error.issues.find((issue) => issue.path[0] === 'email');
        expect(emailError?.message).toBe('Email is required');
      }
    });
  });

  describe('multiple validation errors', () => {
    it('should return all validation errors', () => {
      const invalidData = {
        name: '',
        email: 'invalid',
        country_code: '',
      };

      const result = voteSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues.length).toBeGreaterThan(1);
      }
    });
  });
});


