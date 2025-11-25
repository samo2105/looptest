import { http, HttpResponse } from 'msw'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

export const handlers = [
  http.get(`${API_URL}/api/v1/countries/top`, ({ request }) => {
    const url = new URL(request.url)
    const limit = url.searchParams.get('limit')
    const search = url.searchParams.get('search')

    const mockCountries = [
      {
        country_code: 'USA',
        vote_count: 5,
        name: 'United States',
        official: 'United States of America',
        capital: 'Washington, D.C.',
        region: 'Americas',
        subregion: 'North America',
      },
      {
        country_code: 'CAN',
        vote_count: 3,
        name: 'Canada',
        official: 'Canada',
        capital: 'Ottawa',
        region: 'Americas',
        subregion: 'North America',
      },
      {
        country_code: 'MEX',
        vote_count: 2,
        name: 'Mexico',
        official: 'United Mexican States',
        capital: 'Mexico City',
        region: 'Americas',
        subregion: 'North America',
      },
    ]

    let filtered = mockCountries

    if (search) {
      const searchLower = search.toLowerCase()
      filtered = mockCountries.filter(
        (country) =>
          country.name.toLowerCase().includes(searchLower) ||
          country.region?.toLowerCase().includes(searchLower) ||
          country.subregion?.toLowerCase().includes(searchLower)
      )
    }

    if (limit) {
      const limitNum = parseInt(limit, 10)
      if (!isNaN(limitNum) && limitNum > 0) {
        filtered = filtered.slice(0, limitNum)
      }
    }

    return HttpResponse.json({ countries: filtered }, { status: 200 })
  }),

  http.get(`${API_URL}/api/v1/countries`, () => {
    const mockCountries = [
      { code: 'USA', name: 'United States', official: 'United States of America' },
      { code: 'CAN', name: 'Canada', official: 'Canada' },
      { code: 'MEX', name: 'Mexico', official: 'United Mexican States' },
      { code: 'GBR', name: 'United Kingdom', official: 'United Kingdom of Great Britain and Northern Ireland' },
      { code: 'FRA', name: 'France', official: 'French Republic' },
    ]

    return HttpResponse.json({ countries: mockCountries }, { status: 200 })
  }),

  http.post(`${API_URL}/api/v1/votes`, async ({ request }) => {
    const body = await request.json() as { vote: { name: string; email: string; country_code: string } }
    const { vote } = body

    if (!vote.name || !vote.email || !vote.country_code) {
      return HttpResponse.json(
        { errors: ['Name, email, and country_code are required'] },
        { status: 422 }
      )
    }

    if (vote.email === 'duplicate@example.com') {
      return HttpResponse.json(
        { error: 'User has already voted' },
        { status: 409 }
      )
    }

    if (vote.country_code === 'INVALID') {
      return HttpResponse.json(
        { errors: ['Invalid country code: INVALID'] },
        { status: 422 }
      )
    }

    const mockResponse = {
      vote: {
        id: 1,
        country_code: vote.country_code,
        created_at: new Date().toISOString(),
      },
      user: {
        id: 1,
        name: vote.name,
        email: vote.email,
      },
    }

    return HttpResponse.json(mockResponse, { status: 201 })
  }),
]

