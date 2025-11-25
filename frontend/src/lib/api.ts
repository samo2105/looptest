import axios, { AxiosError } from 'axios'
import type { AxiosInstance, InternalAxiosRequestConfig } from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

export interface ApiError {
  message: string
  errors?: string[]
  status?: number
}

export const api: AxiosInstance = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

api.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('auth_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    const normalizedError: ApiError = {
      message: 'An error occurred',
      status: error.response?.status,
    }

    if (error.response) {
      const data = error.response.data as { error?: string; errors?: string[] | string }
      
      if (data.error) {
        normalizedError.message = data.error
      } else if (data.errors) {
        if (Array.isArray(data.errors)) {
          normalizedError.errors = data.errors
          normalizedError.message = data.errors[0] || normalizedError.message
        } else {
          normalizedError.message = data.errors
        }
      } else if (error.response.status === 409) {
        normalizedError.message = 'User has already voted'
      } else if (error.response.status === 422) {
        normalizedError.message = 'Validation failed'
      } else if (error.response.status >= 500) {
        normalizedError.message = 'Server error. Please try again later.'
      }
    } else if (error.request) {
      normalizedError.message = 'Network error. Please check your connection.'
    } else {
      normalizedError.message = error.message || 'An unexpected error occurred'
    }

    return Promise.reject(normalizedError)
  }
)

export default api

