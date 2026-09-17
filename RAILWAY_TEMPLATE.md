# Railway template configuration

The template's exact configuration. Reproduce it from this file if it ever has to be rebuilt.

| | |
|---|---|
| Name | EdgeEver |
| Code | `edgeever` |
| Template id | `fe05c430-263a-436c-a5fc-0629ce58ba5b` |
| Deploy URL | https://railway.com/deploy/edgeever |
| Category | CMS |
| Card description | Self-hosted AI-native knowledge base & Evernote-style notes app with MCP. |
| Icon | `assets/icon.png` |
| Overview markdown | `marketplace/OVERVIEW.md` (Railway enforces its section headings) |

Generated values use Railway's `secret()` function: `hexN` is `${{secret(N, "abcdef0123456789")}}` and `alnumN` is
`${{secret(N, "a-zA-Z0-9")}}` spelled out. Alphanumeric passwords are used wherever a value is embedded in a
connection URL, so nothing needs percent-encoding. Images are referenced by tag, because the template generator
rejects digests; `UPSTREAM.md` records the digests.

## Services

### `app`

| Field | Value |
|---|---|
| Source | `ghcr.io/tianma-if/edgeever:1.40.0` |
| Public domain | target port 8787 |
| Volume | `/data` |
| Healthcheck | `/api/health`, timeout from `RAILWAY_HEALTHCHECK_TIMEOUT_SEC` |
| Restart policy | on failure, 10 retries |

| Variable | Value |
|---|---|
| `PORT` | `8787` |
| `EDGE_EVER_AUTH_USERNAME` | `admin` |
| `EDGE_EVER_AUTH_PASSWORD` | generated, alnum24 |
| `RAILWAY_RUN_UID` | `0` |
| `RAILWAY_HEALTHCHECK_TIMEOUT_SEC` | `300` |

## Notes

- **Single service, official image unmodified — no wrapper.** SQLite + files on the `/data` volume; the server (Bun)
  serves the web app + API + MCP on port 8787. Health `/api/health` (auth-exempt).
- **Admin from env, no bootstrap race.** `EDGE_EVER_AUTH_USERNAME` (admin) + generated `EDGE_EVER_AUTH_PASSWORD`
  define the admin at boot, so there is no first-run create-admin step to race. Login `POST /api/v1/auth/login` →
  session cookie (rate-limited); `/api/v1/*` needs it (401 without / on a wrong password).
- **`RAILWAY_RUN_UID=0`** — the image runs as non-root `bun`; Railway mounts volumes as root, so this lets the
  process write `/data`.
- **`PORT` = 8787** = the domain target port.
- **Brand:** EdgeEver's name/logo are the project's marks (not covered by the AGPL). This template is
  community-maintained, states only that it is based on EdgeEver, ships its own generic icon (no EdgeEver logo), and
  does not imply official status.
