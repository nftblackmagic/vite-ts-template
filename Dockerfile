# syntax = docker/dockerfile:1

# Adjust NODE_VERSION as desired
ARG NODE_VERSION=20.18.2
FROM node:${NODE_VERSION}-slim AS base

LABEL fly_launch_runtime="Vite"

# Vite app lives here
WORKDIR /app

# Set production environment
# ENV NODE_ENV="production"


# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential node-gyp pkg-config python-is-python3

# Install node modules
COPY package.json ./
RUN npm install --include=dev

# Copy application code
COPY . .

# Build application
RUN npm run build

# # Remove development dependencies
# RUN npm prune --omit=dev


# Ensure /app exists and has correct permissions for the node user
RUN mkdir -p /app && chown -R node:node /app
# Run as non-root user
USER node


# Start the server by default, this can be overwritten at runtime
EXPOSE 8080

CMD [ "npm", "run", "dev" ]