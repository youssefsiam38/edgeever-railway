# Security

## The admin login gates the API

EdgeEver requires an admin login. This template sets the admin account from environment variables —
`EDGE_EVER_AUTH_USERNAME` (default `admin`) and a **generated** `EDGE_EVER_AUTH_PASSWORD` — so the API is protected
from the first boot, with no first-run "create admin" step that a stranger could claim on a public URL. Every
`/api/v1/*` route requires a valid session (obtained by `POST /api/v1/auth/login`); a request without one, or a
wrong password, is rejected (`401`). Verified in the smoke, persistence and live tests.

## What the template does

- **Generated admin password** (`EDGE_EVER_AUTH_PASSWORD`, 24 alphanumerics) — copy it from the service variables to
  sign in. Login has built-in rate limiting.
- **Pinned image.** The official image is pinned by digest (see `UPSTREAM.md`); the application is unmodified.
- **Secret hygiene.** No secret is committed; the tests read the password from a mode-restricted file over HTTPS and
  never print it; the static test greps the tree for credential shapes.

## What you should do

- **Copy and guard `EDGE_EVER_AUTH_PASSWORD`.** Anyone with it can read and manage your notes. Rotate it by changing
  the variable.
- **Your AI provider key is yours.** Configure it in the app; it is stored with the app's data on the volume.
- **Back up the `/data` volume** (SQLite + files) with Railway's volume backups.

## Reporting

For issues in EdgeEver itself, report upstream. For issues specific to this template's packaging, open an issue on
the template repository.
