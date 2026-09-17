# Architecture

## Service graph

```
        Railway HTTPS edge
              │
              ▼
   ┌─────────────────────────────────────────────┐
   │  app  (public domain :8787)                  │  volume: /data
   │  the EdgeEver self-hosted server:            │   - SQLite (notebooks, memos, users, sessions)
   │   - web app          GET /                    │   - uploaded files / resources
   │   - REST API         /api/v1/*  (session)     │
   │   - MCP endpoint                              │
   │   - health           /api/health  (no auth)   │
   └─────────────────────────────────────────────┘
```

One service. EdgeEver runs a single self-hosted server (Bun) that serves the web app, the API and the MCP endpoint,
storing everything in SQLite and files on the `/data` volume.

## The app service

- Image: the official `ghcr.io/tianma-if/edgeever`, pinned by digest, used unmodified.
- **Port:** `8787`. The template sets `PORT=8787`, the public domain's target port to `8787`, and the health check
  to `/api/health` (auth-exempt) — all aligned.
- **Admin from env.** `EDGE_EVER_AUTH_USERNAME` (default `admin`) and the generated `EDGE_EVER_AUTH_PASSWORD` define
  the admin account. Login is `POST /api/v1/auth/login` (username + password → session cookie, with built-in
  rate-limiting); the API routes (`/api/v1/*`) require the session and return `401` without it. Because the admin is
  configured from environment variables, there is no first-run "create admin" step to race on a public URL.
- **Volume:** `/data` holds the SQLite database and uploaded files. The image runs as the non-root `bun` user, so
  the template sets `RAILWAY_RUN_UID=0` (Railway mounts volumes as root; this lets the process own its data dir).

## Data & AI

Notebooks, memos and resources live in SQLite/files on the volume. AI features (generation, etc.) call an AI
provider you configure in the app's settings — your own credential, stored with the app's data.
