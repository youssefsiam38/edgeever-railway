# EdgeEver on Railway

A one-click [Railway](https://railway.com) template that runs [EdgeEver](https://github.com/tianma-if/edgeever) —
an open-source, AI-native knowledge base and Evernote-style notes app with native MCP. A single self-hosted service,
with your **admin account and password set from the template's variables**.

> **Community-maintained and not affiliated.** This template is based on EdgeEver but is **not affiliated with,
> endorsed by, or an official offering of** the EdgeEver project, and it does not use the EdgeEver logo. See
> [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

- **Image:** the official `ghcr.io/tianma-if/edgeever`, pinned by digest, used unmodified — see
  [UPSTREAM.md](UPSTREAM.md)
- EdgeEver is **AGPL-3.0**; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for what that means for you.

## What you get

- One service: the EdgeEver web app + API + MCP endpoint, with SQLite and files on a `/data` volume.
- A **generated admin password** (`EDGE_EVER_AUTH_PASSWORD`, username `admin`). The app requires a login, so a
  stranger who finds your URL cannot read or change your notes.

## Deploy

1. Click **Deploy on Railway** and wait for the service to go healthy.
2. Open the service → **Variables** and copy `EDGE_EVER_AUTH_PASSWORD` (username `EDGE_EVER_AUTH_USERNAME`, default
   `admin`).
3. Open the public domain and sign in.

## Use it

Create notebooks and memos, capture with the web clipper, and connect an MCP client to your knowledge base. To use
the AI features, configure an AI provider in the app's settings — that is your own credential.

## Security

- The admin login gates the API; treat `EDGE_EVER_AUTH_PASSWORD` like a password and rotate it by changing the
  variable. See [SECURITY.md](SECURITY.md).

## Repository layout

| Path | What |
|---|---|
| `compose.yaml` | Local test topology (the official image + a volume) |
| `tests/` | Static, smoke, persistence, and live (HTTPS) tests |
| `marketplace/OVERVIEW.md` | The marketplace overview shown on the template page |
| `RAILWAY_TEMPLATE.md` | The exact published template configuration |
| `UPSTREAM.md` · `SECURITY.md` · `ARCHITECTURE.md` · `MAINTENANCE.md` | Reference docs |

## Local development

```bash
EDGEEVER_TEST_PASSWORD=change-me docker compose up   # run the official image with a volume
tests/smoke.sh                                        # health, login gate, authed API
tests/persistence.sh                                  # a notebook survives a restart
```

## Licence

The template's own files are MIT (`LICENSE`). EdgeEver is AGPL-3.0; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
