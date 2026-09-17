# Marketplace audit

A record of the diligence behind publishing this template.

## Identity

- Template: **EdgeEver** — an AI-native knowledge base / Evernote-style notes app with native MCP.
- Upstream: [tianma-if/edgeever](https://github.com/tianma-if/edgeever), AGPL-3.0, active (~1.4k stars).

## Licence and brand

- **AGPL-3.0** (`licenses/EDGEEVER-LICENSE`). Running it as a template is permitted; the image is used unmodified,
  so no additional source-disclosure obligation is created by this template.
- **Brand.** "EdgeEver" and its logo are the project's marks and are not covered by the AGPL. This template is
  community-maintained, states only that it is based on EdgeEver, does not use the EdgeEver logo (it ships its own
  generic icon), and does not imply official status. See `THIRD_PARTY_NOTICES.md`.

## Security review

- **Admin login enforced, no bootstrap race.** The admin account is set from `EDGE_EVER_AUTH_USERNAME` and a
  generated `EDGE_EVER_AUTH_PASSWORD`, so the API is protected from first boot with no first-run create-admin step.
  `/api/v1/*` requires a session; no session or a wrong password → `401`, verified live.
- **Secret hygiene.** The admin password is generated; the tests read it from a mode-restricted file and never print
  it; the static test greps the tree for credential shapes.
- **Reproducible.** The image is pinned by digest.

## Reproducibility & tests

- `tests/static.sh` (15 checks): syntax, shellcheck, compose shape, digest pin, admin-auth wiring, secret scan.
- `tests/smoke.sh` (7 checks): health, web app served, the `/api/v1/memos` 401 gate, a wrong password rejected, the
  admin logs in, and an authenticated API call works.
- `tests/persistence.sh` (4 checks): a notebook created through the API survives a restart (SQLite on the volume).
- `tests/railway-smoke.sh`: the same flows over HTTPS against the deployed template.
- CI runs static + smoke + persistence on every push (no image build — the official image is used unmodified).

## Deploy-time inputs

- `EDGE_EVER_AUTH_PASSWORD` — generated (the admin password; copy it to sign in). `EDGE_EVER_AUTH_USERNAME` defaults
  to `admin`.
- Everything else is fixed by the template (port, health check, volume, run-as-root). No required human input beyond
  clicking deploy; using the AI features needs your own AI provider key, configured in the app.

## Verdict

Shippable. A self-contained, reproducible, admin-authenticated single-service deployment whose auth and persistence
are verified on a live Railway deployment, with brand use limited per the project's policy.
