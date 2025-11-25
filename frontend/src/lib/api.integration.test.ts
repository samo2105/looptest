import { describe, it, expect } from 'vitest'
import { http, HttpResponse } from 'msw'
import { server } from '../mocks/server'
import api from './api'

describe('API Integration with MSW', () => {
  describe('GET /api/v1/countries/top', () => {
    it('should fetch top countries successfully', async () => {
      const response = await api.get('/api/v1/countries/top')
      
      expect(response.status).toBe(200)
      expect(response.data).toHaveProperty('countries')
      expect(Array.isArray(response.data.countries)).toBe(true)
      expect(response.data.countries.length).toBeGreaterThan(0)
      expect(response.data.countries[0]).toHaveProperty('country_code')
      expect(response.data.countries[0]).toHaveProperty('vote_count')
    })

    it('should handle limit parameter', async () => {
      const response = await api.get('/api/v1/countries/top', {
        params: { limit: 2 },
      })

      expect(response.status).toBe(200)
      expect(response.data.countries.length).toBeLessThanOrEqual(2)
    })

    it('should handle search parameter', async () => {
      const response = await api.get('/api/v1/countries/top', {
        params: { search: 'United' },
      })

      expect(response.status).toBe(200)
      expect(response.data.countries.length).toBeGreaterThan(0)
      expect(
        response.data.countries.some((c: any) =>
          c.name.toLowerCase().includes('united')
        )
      ).toBe(true)
    })

    it('should handle both limit and search parameters', async () => {
      const response = await api.get('/api/v1/countries/top', {
        params: { limit: 1, search: 'United' },
      })

      expect(response.status).toBe(200)
      expect(response.data.countries.length).toBeLessThanOrEqual(1)
    })
  })

  describe('GET /api/v1/countries', () => {
    it('should fetch all countries successfully', async () => {
      const response = await api.get('/api/v1/countries')

      expect(response.status).toBe(200)
      expect(response.data).toHaveProperty('countries')
      expect(Array.isArray(response.data.countries)).toBe(true)
      expect(response.data.countries.length).toBeGreaterThan(0)
      expect(response.data.countries[0]).toHaveProperty('code')
      expect(response.data.countries[0]).toHaveProperty('name')
    })
  })

  describe('POST /api/v1/votes', () => {
    it('should create a vote successfully', async () => {
      const voteData = {
        vote: {
          name: 'John Doe',
          email: 'john@example.com',
          country_code: 'USA',
        },
      }

      const response = await api.post('/api/v1/votes', voteData)

      expect(response.status).toBe(201)
      expect(response.data).toHaveProperty('vote')
      expect(response.data).toHaveProperty('user')
      expect(response.data.vote.country_code).toBe('USA')
      expect(response.data.user.name).toBe('John Doe')
      expect(response.data.user.email).toBe('john@example.com')
    })

    it('should handle duplicate email error (409)', async () => {
      const voteData = {
        vote: {
          name: 'Jane Doe',
          email: 'duplicate@example.com',
          country_code: 'CAN',
        },
      }

      try {
        await api.post('/api/v1/votes', voteData)
        expect.fail('Should have thrown an error')
      } catch (error: any) {
        expect(error.status).toBe(409)
        expect(error.message).toBe('User has already voted')
      }
    })

    it('should handle invalid country code error (422)', async () => {
      const voteData = {
        vote: {
          name: 'Test User',
          email: 'test@example.com',
          country_code: 'INVALID',
        },
      }

      try {
        await api.post('/api/v1/votes', voteData)
        expect.fail('Should have thrown an error')
      } catch (error: any) {
        expect(error.status).toBe(422)
        expect(error.message).toContain('Invalid country code')
      }
    })

    it('should handle missing required fields (422)', async () => {
      const voteData = {
        vote: {
          name: '',
          email: '',
          country_code: '',
        },
      }

      try {
        await api.post('/api/v1/votes', voteData)
        expect.fail('Should have thrown an error')
      } catch (error: any) {
        expect(error.status).toBe(422)
        expect(error.message).toContain('required')
      }
    })

    it('should handle server error (500)', async () => {
      server.use(
        http.post('*/api/v1/votes', () => {
          return HttpResponse.json(
            {},
            { status: 500 }
          )
        })
      )

      const voteData = {
        vote: {
          name: 'Test User',
          email: 'test@example.com',
          country_code: 'USA',
        },
      }

      try {
        await api.post('/api/v1/votes', voteData)
        expect.fail('Should have thrown an error')
      } catch (error: any) {
        expect(error.status).toBe(500)
        expect(error.message).toBe('Server error. Please try again later.')
      }
    })
  })
})

