# CountryVote Backend API

Rails 8.1 API backend for vote submissions and country leaderboards.

## Prerequisites

- Ruby 3.4.4 (see `.ruby-version`)
- PostgreSQL 16+, Redis 7+

## Application Overview

**Features:** Single vote per user, country validation, Redis caching (24h metadata, 1h vote checks), background jobs, OpenAPI docs.

**Components:** `Votes::Create`, `Countries::TopQuery`, `Countries::RefreshJob`, `Countries::Client`

## Local Development

**All commands run from the `backend` directory.**

### Setup

```bash
bundle install
cp .env.example .env
rails db:create db:migrate db:seed
rails server          # Terminal 1
bundle exec sidekiq   # Terminal 2
```

**Seeding the Database:**
The seed file (`db/seeds.rb`) creates sample votes for 14 countries with varied vote counts (ranging from 1 to 25 votes), ensuring a complete top 10 leaderboard is displayed. To seed or reseed the database:

```bash
# Seed the database
rails db:seed

# Reset and reseed (drops all data first)
rails db:reset
```

The seed data includes votes for: USA (25), Canada (18), Mexico (15), UK (12), France (10), Germany (9), Italy (8), Spain (7), Japan (6), Australia (5), and a few more countries with lower counts.

## Testing

```bash
bundle exec rspec                    # All tests
bundle exec rspec spec/models        # Models only
bundle exec rspec spec/services      # Services only
bundle exec rspec spec/requests      # API endpoints
bin/ci                               # CI script (tests + linting)
```

## API Endpoints

### POST /api/v1/votes
Submit a vote for a country.

**Request:**
```json
{
  "vote": {
    "name": "John Doe",
    "email": "john@example.com",
    "country_code": "USA"
  }
}
```

**Responses:** `201 Created`, `409 Conflict` (already voted), `422 Unprocessable Entity` (validation errors)

### GET /api/v1/countries/top
Get top countries by vote count.

**Query Parameters:** `limit` (default: 10), `search` (optional, filters by name/region/subregion)

**Response:**
```json
{
  "countries": [{
    "country_code": "USA",
    "vote_count": 15,
    "name": "United States",
    "official": "United States of America",
    "capital": "Washington, D.C.",
    "region": "Americas",
    "subregion": "North America"
  }]
}
```

### GET /api/v1/countries
Get list of all countries (for dropdown).

## Development Commands

```bash
rails console                        # Rails console
rails dbconsole                      # Database console
rails generate model User name:string
rails generate service Votes::Create
bundle exec rubocop -A               # Auto-fix linting
bundle exec rake rswag:specs:swaggerize  # Regenerate OpenAPI spec
```

## Models

**User:** `id`, `name`, `email`, `timestamps` | Validations: name (presence), email (presence, format, uniqueness) | Callback: `before_validation :normalize_email`

**Vote:** `id`, `user_id`, `country_code`, `timestamps` | Validations: country_code (presence), user_id (uniqueness) | Association: `belongs_to :user`

## Environment Variables

See `.env.example`. Key variables:
- `DATABASE_*` - PostgreSQL connection
- `REDIS_URL` - Redis for Sidekiq
- `REDIS_CACHE_URL` - Redis for caching
- `REST_COUNTRIES_API_URL` - API endpoint (default: https://restcountries.com/v3.1)
- `CORS_ORIGINS` - Allowed origins (default: http://localhost:5173)

## Caching

**Cache Keys:**
- `country:{CODE}` - Country metadata (24h TTL)
- `country_has_votes:{CODE}` - Vote existence (1h TTL)
- `countries:all` - All countries (24h TTL)

## Troubleshooting

**Database:** `rails db:version`, `rails db:create`  
**Redis:** `redis-cli ping`, check `REDIS_URL`  
**Port conflicts:** `lsof -ti:3000 | xargs kill` or `rails server -p 3001`  
**Gems:** `bundle install --force`, verify Ruby version matches `.ruby-version`

## Documentation

- **API Docs**: http://localhost:3000/api-docs (when server running)
