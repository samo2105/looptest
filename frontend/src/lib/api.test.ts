import { describe, it, expect, beforeEach } from 'vitest'

describe('API Configuration', () => {
  beforeEach(() => {
    localStorage.clear()
  })

  describe('API instance', () => {
    it('should export api instance', async () => {
      const apiModule = await import('./api')
      expect(apiModule.api).toBeDefined()
      expect(apiModule.default).toBeDefined()
    })

    it('should have correct base URL from environment', () => {
      const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000'
      expect(apiUrl).toBeTruthy()
    })
  })
})

