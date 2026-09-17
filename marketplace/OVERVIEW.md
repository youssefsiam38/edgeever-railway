# Deploy and Host EdgeEver on Railway

EdgeEver is an open-source, AI-native knowledge base and Evernote-style notes app with native MCP support. This
template deploys the self-hosted EdgeEver server with your admin account set from the template's variables. It is a
community-maintained template based on EdgeEver; it is not affiliated with, endorsed by, or an official offering of
the EdgeEver project, and it does not use the EdgeEver logo.

## About Hosting EdgeEver

EdgeEver runs as a single self-hosted server that serves its web app, its API and its MCP endpoint, storing
everything in SQLite and files on disk. It requires an admin login, and the admin account is configured from
environment variables — so if that password is left as a weak default (or unset), the instance could be signed into
by anyone who finds it.

This template runs EdgeEver on Railway with a generated admin password (so the API is protected from the first
boot), its data persisted on a volume, and the port and health check wired. It runs the official image unmodified,
pinned by digest.

## Common Use Cases

- A private, self-hosted notes and knowledge base with an Evernote-style workflow.
- An AI-native knowledge base you can query from AI clients over MCP.
- A personal capture-and-organize hub with web-clipper support, hosted on your own infrastructure.

## Dependencies for EdgeEver Hosting

- Nothing external — the database is embedded (SQLite on the volume) and files live alongside it.
- To use the AI features you provide your own AI provider key, configured in the app's settings.

### Deployment Dependencies

- EdgeEver: https://github.com/tianma-if/edgeever (AGPL-3.0)
- Template repository and tests: https://github.com/youssefsiam38/edgeever-railway

### Implementation Details

EdgeEver runs upstream's official self-hosted image, pinned by digest and unmodified. The template sets the admin
account from `EDGE_EVER_AUTH_USERNAME` (default `admin`) and a generated `EDGE_EVER_AUTH_PASSWORD`, so the API is
behind a login from first boot with no first-run create-admin step to race; every `/api/v1/*` route requires a
session and rejects requests without one. It sets `RAILWAY_RUN_UID=0` so the non-root image can write its `/data`
volume (SQLite + files), and wires `PORT` (8787), the public domain and the `/api/health` check.

Tested in CI and on a live deployment of this template: the app is healthy, the web app is served, the API rejects a
request with no session or a wrong password and accepts the correct admin login, and a notebook created through the
API survives a redeploy.

After deploying, copy `EDGE_EVER_AUTH_PASSWORD` from the service's variables and sign in at the app's domain
(username `admin`). To use the AI features, configure an AI provider in the app's settings.

## Why Deploy EdgeEver on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you
don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying EdgeEver on Railway, you are one step closer to supporting a complete full-stack application with
minimal burden. Host your servers, databases, AI agents, and more on Railway.
