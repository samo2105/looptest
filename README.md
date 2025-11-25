# CountryVote

A full-stack application that allows users to vote for their favorite countries and view a leaderboard of the most popular countries.

## Architecture

This is a monorepo containing:
- **Backend**: Rails 8.1 API (`/backend`) - RESTful API with PostgreSQL, Redis, and Sidekiq
- **Frontend**: React 19 + Vite + TypeScript + Tailwind CSS (`/frontend`) - Modern SPA with React Query for data fetching

## Quick Start with Docker Compose

### Prerequisites
- Docker and Docker Compose

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd fullstack_challenge
```

2. Create environment files (if needed):
```bash
# Backend environment variables can be set in docker-compose.yml or .env file
# Frontend environment variables (optional):
# Create frontend/.env with: VITE_API_URL=http://localhost:3000
```

3. Start all services:
```bash
docker compose up -d
```

4. Setup database:
```bash
docker compose run --rm api bundle exec rails db:create
docker compose run --rm api bundle exec rails db:migrate
docker compose run --rm api bundle exec rails db:seed
```

**Note:** The seed data creates sample votes for 14 countries with varied vote counts, ensuring a complete top 10 leaderboard is displayed. To reset and reseed the database, run:
```bash
docker compose run --rm api bundle exec rails db:reset
```

### Access Services
- **Backend API**: http://localhost:3000
- **API Documentation**: http://localhost:3000/api-docs
- **Sidekiq Dashboard**: http://localhost:3000/sidekiq
- **Frontend**: http://localhost:5173

## Docker Compose Commands

### Basic Operations
```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f [service]  # api, sidekiq, db, redis, frontend

# Rebuild containers
docker compose build
```

### Run Commands in Containers

**Backend (API) Commands:**
```bash
# Rails console
docker compose run --rm api bundle exec rails console

# Run tests
docker compose run --rm api bundle exec rspec

# Database migrations
docker compose run --rm api bundle exec rails db:migrate

# Database console
docker compose run --rm api bundle exec rails dbconsole
```

**Frontend Commands:**
```bash
# Install dependencies
docker compose run --rm frontend npm install

# Start development server
docker compose up frontend

# Build for production
docker compose run --rm frontend npm run build

# Run linter
docker compose run --rm frontend npm run lint

# Run tests
docker compose run --rm frontend npm run test

# Access frontend container shell
docker compose exec frontend sh
```

### Cleanup
```bash
# Remove all containers and volumes
docker compose down -v

# Rebuild from scratch
docker compose build --no-cache
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| Backend API | 3000 | Rails API server with OpenAPI docs |
| Frontend | 5173 | React dev server with HMR |
| PostgreSQL | 5432 | Database |
| Redis | 6379 | Cache and job queue |

## Frontend Application

The frontend is a modern React application built with:
- **React 19** with TypeScript for type safety
- **Vite 7** for fast development and optimized builds
- **Tailwind CSS 3** for utility-first styling
- **React Query (TanStack Query)** for server state management
- **Axios** for HTTP requests
- **React Hook Form + Zod** for form validation

### Frontend Features
- Hot Module Replacement (HMR) for instant updates
- TypeScript for compile-time error checking
- Responsive design with Tailwind CSS
- Optimized production builds
- Test suite with Vitest

### Running Frontend Locally (without Docker)

If you prefer to run the frontend locally:

```bash
cd frontend
npm install
npm run dev
```

The frontend will be available at `http://localhost:5173`.

For more detailed frontend documentation, see [frontend/README.md](frontend/README.md).

## Troubleshooting

### Port Conflicts
Stop conflicting services or modify port mappings in `docker-compose.yml`.

### Database Issues
```bash
# Reset database
docker compose run --rm api bundle exec rails db:drop db:create db:migrate db:seed

# Or use db:reset (drops, creates, migrates, and seeds in one command)
docker compose run --rm api bundle exec rails db:reset
```

### Container Issues
```bash
# Rebuild containers
docker compose build --no-cache
docker compose down -v
```

## Technology Stack

**Backend**: Rails 8.1, PostgreSQL 16, Redis 7, Sidekiq, RSpec, OpenAPI  
**Frontend**: React 19, Vite 7, TypeScript 5.9, Tailwind CSS 3, React Query 5, Axios, React Hook Form, Zod

## Documentation

- **Backend**: [backend/README.md](backend/README.md)
- **Frontend**: [frontend/README.md](frontend/README.md)
