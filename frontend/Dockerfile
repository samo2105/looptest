FROM node:22-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application files
COPY . .

# Expose Vite dev server port
EXPOSE 5173

# Start development server
# Note: --host is already configured in vite.config.ts, but keeping it here for explicit container networking
CMD ["npm", "run", "dev", "--", "--host"]

