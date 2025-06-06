# ---------- Stage 1: build the app ----------
FROM node:lts-alpine AS builder

ARG REPO_REF=develop
ARG UPSTREAM_REPO=https://github.com/live-codes/livecodes

WORKDIR /app

# 1. Install Git so we can clone a specific ref
RUN apk update && \
    apk add --no-cache git

# 2. Clone the upstream repo at the desired ref (branch or tag)
RUN git clone --depth 1 --branch "${REPO_REF}" "${UPSTREAM_REPO}" .

# 3. Install JS dependencies (skip postinstall scripts to avoid surprises)
RUN npm ci --ignore-scripts

# 4. Patch package.json so that `npm run build` only runs "build:app"
RUN node -e "\
  const fs = require('fs'); \
  const pkg = JSON.parse(fs.readFileSync('package.json')); \
  pkg.scripts.build = 'run-s build:app'; \
  fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));"

# 5. Build the production bundle
RUN npm run build

# ---------- Stage 2: serve with nginx ----------
FROM nginx:stable-alpine

# Clear out default static files
RUN rm -rf /usr/share/nginx/html/*

# Copy the build artifacts from the builder stage
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
