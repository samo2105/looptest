# CountryVote Frontend

A modern React application built with Vite, TypeScript, and Tailwind CSS for voting on favorite countries and viewing a leaderboard.

## Technology Stack

- **React 19** - UI library
- **TypeScript** - Type safety
- **Vite 7** - Build tool and dev server
- **Tailwind CSS 3** - Utility-first CSS framework
- **React Query (TanStack Query)** - Data fetching and caching
- **Axios** - HTTP client
- **React Hook Form** - Form management
- **Zod** - Schema validation
- **Vitest** - Testing framework
- **ESLint** - Code linting

## Prerequisites

Before starting, ensure you have the following installed:

- **Node.js** (v18 or higher recommended)
- **npm** (v9 or higher) - comes with Node.js

To check your versions:
```bash
node --version
npm --version
```

## Installation

1. **Navigate to the frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

   This will install all required packages listed in `package.json`.

## Configuration

### Environment Variables

The frontend uses environment variables prefixed with `VITE_` (required by Vite). Create a `.env` file in the `frontend` directory if you need to customize the API URL:

```bash
# .env
VITE_API_URL=http://localhost:3000
```

**Default values:**
- `VITE_API_URL` defaults to `http://localhost:3000` (backend API URL)

**Note:** After changing environment variables, restart the dev server.

## Development

### Start Development Server

```bash
npm run dev
```

This will:
- Start the Vite development server
- Enable Hot Module Replacement (HMR)
- Open the app at `http://localhost:5173`
- Watch for file changes and auto-reload

The server will be available at:
- **Local:** http://localhost:5173
- **Network:** http://[your-ip]:5173

### Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server with HMR |
| `npm run build` | Build for production (outputs to `dist/`) |
| `npm run preview` | Preview production build locally |
| `npm run lint` | Run ESLint to check code quality |
| `npm run test` | Run tests with Vitest |
| `npm run test:ui` | Run tests with Vitest UI |
| `npm run test:coverage` | Run tests with coverage report |

## Project Structure

```
frontend/
├── public/              # Static assets
├── src/
│   ├── assets/         # Images, icons, etc.
│   ├── test/           # Test setup files
│   ├── App.tsx         # Main app component
│   ├── App.css         # App styles
│   ├── main.tsx        # Application entry point
│   └── index.css       # Global styles (Tailwind imports)
├── index.html          # HTML template
├── package.json        # Dependencies and scripts
├── tsconfig.json       # TypeScript configuration
├── vite.config.ts      # Vite configuration
├── tailwind.config.js  # Tailwind CSS configuration
├── postcss.config.js   # PostCSS configuration
└── vitest.config.ts    # Vitest test configuration
```

## Building for Production

1. **Build the application:**
   ```bash
   npm run build
   ```

   This will:
   - Compile TypeScript
   - Bundle and optimize assets
   - Output to the `dist/` directory

2. **Preview the production build:**
   ```bash
   npm run preview
   ```

   This serves the `dist/` folder locally to test the production build.

## Testing

### Run Tests

```bash
npm run test
```

### Run Tests with UI

```bash
npm run test:ui
```

### Generate Coverage Report

```bash
npm run test:coverage
```

## Code Quality

### Linting

Check code quality and style:
```bash
npm run lint
```

ESLint is configured with:
- TypeScript support
- React hooks rules
- React refresh plugin

## Backend Integration

The frontend expects the backend API to be running at `http://localhost:3000` by default. Make sure:

1. **Backend is running:**
   ```bash
   # From project root
   docker compose up api
   # Or if running locally
   cd ../backend && rails server
   ```

2. **CORS is configured** - The backend should allow requests from `http://localhost:5173`

3. **API endpoints available:**
   - `POST /api/v1/votes` - Create a vote
   - `GET /api/v1/countries/top` - Get top countries
   - `GET /api/v1/countries` - Get all countries

## Troubleshooting

### Port Already in Use

If port 5173 is already in use, Vite will automatically try the next available port. You can also specify a different port:

```bash
npm run dev -- --port 3001
```

### Dependencies Not Installing

If you encounter issues installing dependencies:

```bash
# Clear npm cache
npm cache clean --force

# Remove node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Build Errors

If the build fails:

1. **Check TypeScript errors:**
   ```bash
   npx tsc --noEmit
   ```

2. **Check for missing dependencies:**
   ```bash
   npm install
   ```

3. **Clear build cache:**
   ```bash
   rm -rf dist node_modules/.vite
   npm run build
   ```

### Tailwind CSS Not Working

If Tailwind styles aren't applying:

1. Ensure `tailwindcss` is installed:
   ```bash
   npm list tailwindcss
   ```

2. Verify `tailwind.config.js` includes your source files

3. Check that `src/index.css` imports Tailwind:
   ```css
   @tailwind base;
   @tailwind components;
   @tailwind utilities;
   ```

### API Connection Issues

If the frontend can't connect to the backend:

1. **Verify backend is running:**
   ```bash
   curl http://localhost:3000/api/v1/countries
   ```

2. **Check CORS configuration** in the backend (`config/initializers/cors.rb`)

3. **Verify environment variable:**
   ```bash
   echo $VITE_API_URL
   ```

4. **Check browser console** for CORS or network errors

## Development Tips

- **Hot Module Replacement (HMR)** - Changes to React components will update instantly without full page reload
- **TypeScript** - Use type definitions for better IDE support and catch errors early
- **React Query** - Automatically handles caching, refetching, and loading states
- **Tailwind CSS** - Use utility classes for rapid UI development
- **ESLint** - Fix auto-fixable issues with: `npm run lint -- --fix`

## Docker Development

If you prefer using Docker:

```bash
# From project root
docker compose up frontend
```

The frontend will be available at `http://localhost:5173` with hot reload enabled.

## Additional Resources

- [Vite Documentation](https://vite.dev/)
- [React Documentation](https://react.dev/)
- [TypeScript Documentation](https://www.typescriptlang.org/)
- [Tailwind CSS Documentation](https://tailwindcss.com/)
- [React Query Documentation](https://tanstack.com/query/latest)
- [React Hook Form Documentation](https://react-hook-form.com/)

## Support

For issues or questions, please refer to the main project README or open an issue in the repository.
