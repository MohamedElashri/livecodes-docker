# Livecodes Docker

A minimal repository that automatically builds the Livecodes web app into Docker image.

## Overview

* **Dockerfile**:

  * Clones the upstream Livecodes repo at a given branch or tag (default: `develop`).
  * Installs dependencies, builds the React app, and serves it with Nginx.

* **GitHub Actions** (`.github/workflows/ci.yml`):

  * Runs daily (or on demand), checks the latest release of `live-codes/livecodes`.
  * If a new tag appears, builds and pushes `melashri/livecodes:latest` and `melashri/livecodes:<TAG>` to Docker Hub, then tags this repo.

* **docker-compose.yml**:

  * Pulls `melashri/livecodes:latest` and runs a single container on port 80 with a basic healthcheck.

---

## Quick Start

1. **CI Workflow**

   * Automatically runs daily to detect new upstream releases.
   * Builds and pushes fresh Docker images when a new tag appears.

2. **Manual Build (optional)**

   ```bash
   docker build \
     --build-arg REPO_REF=develop \
     --build-arg UPSTREAM_REPO=https://github.com/live-codes/livecodes.git \
     -t melashri/livecodes:local .
   docker run --rm -p 8080:80 melashri/livecodes:local
   ```

   * Change `REPO_REF` to any branch or tag (e.g. `v46`).

3. **Deploy via Docker Compose**

   ```bash
   docker-compose pull
   docker-compose up -d
   ```

   * Exposes port 80.
   * Healthcheck verifies `http://localhost/` inside the container.

---

## File Structure

```
.
├── Dockerfile
├── docker-compose.yml
├── README.md
└── .github
    └── workflows
        └── ci.yml
```

* **Dockerfile**: Multi‐stage build (Node → Nginx).
* **docker-compose.yml**: Runs `melashri/livecodes:latest`.
* **ci.yml**: Daily CI that tags new upstream releases.

---

## Deployment 

* To use a specific release tag instead of `latest`, edit `docker-compose.yml`:

  ```yaml
  image: melashri/livecodes:v46
  ```

  Then run:

  ```bash
  docker-compose pull
  docker-compose up -d
  ```
