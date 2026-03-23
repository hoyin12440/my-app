# ── Stage 1: Build ────────────────────────────────────────────────────────────
# Use an official Node LTS image as the build environment.
# "alpine" keeps the image size small.
FROM node:22-alpine AS builder

# Set the working directory inside the container.
WORKDIR /app

# Copy only the package manifest files first so Docker can cache the
# dependency-install layer — it won't re-run `npm ci` unless these files change.
COPY package.json package-lock.json ./

# Install ALL dependencies (including devDependencies needed to compile).
# `npm ci` is preferred over `npm install` in CI/Docker: it is faster, strictly
# respects package-lock.json, and errors on any mismatch.
RUN npm ci

# Copy the rest of the source code into the image.
COPY . .

# Compile the SvelteKit app.  adapter-node writes a self-contained Node.js
# server into the `build/` directory.
RUN npm run build

# ── Stage 2: Production runtime ───────────────────────────────────────────────
# Start fresh from the same slim base — the final image contains NO build
# tools, source code, or devDependencies, keeping it lean and secure.
FROM node:22-alpine AS runner

WORKDIR /app

# Copy the manifest files so we can install only production dependencies.
COPY package.json package-lock.json ./

# `--omit=dev` skips devDependencies (compilers, type checkers, etc.)
# that are not needed at runtime.
RUN npm ci --omit=dev

# Copy the compiled output from the builder stage.
COPY --from=builder /app/build ./build

# Tell SvelteKit's Node adapter to listen on every network interface
# (0.0.0.0) so that traffic can reach the container from outside.
ENV HOST=0.0.0.0

# The adapter defaults to port 3000; set it explicitly so it is obvious.
ENV PORT=3000

# Declare the port to Docker/orchestrators (does not publish it on its own —
# you still need `-p 3000:3000` when running `docker run`).
EXPOSE 3000

# Start the production server.  `build/index.js` is the entry point written
# by @sveltejs/adapter-node.
CMD ["node", "build/index.js"]
