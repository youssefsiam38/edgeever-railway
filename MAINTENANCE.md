# Maintenance

## Updating to a new upstream version

1. **Bump the pin.** Get the new digest (see `UPSTREAM.md`) and update `compose.yaml` and `_audit/spec_edgeever.py`,
   and re-point the template's `app` image at the new tag.
2. **Run the tests locally.**
   ```bash
   tests/static.sh
   tests/smoke.sh
   tests/persistence.sh
   ```
3. **Re-verify on Railway.** Re-run the clean-room deploy + `tests/railway-smoke.sh` before updating the published
   template.

There is no wrapper image to build or publish — the template runs the official image unmodified, so CI only runs
the tests.

## Rebuilding the Railway template from scratch

The exact configuration is in `RAILWAY_TEMPLATE.md`. The generator spec is `_audit/spec_edgeever.py`; the kit in
`_audit/` (`tplkit.py`) builds a skeleton, patches the template, and runs a clean-room deploy. Volumes, domains and
health checks are only set by `skeleton()`, so a change to those requires rebuilding from a skeleton; if
`verify_template` reports an empty volume right after create, delete the template and re-create it.

## Gotchas worth remembering

- **Admin from env, no bootstrap race.** `EDGE_EVER_AUTH_USERNAME`/`EDGE_EVER_AUTH_PASSWORD` define the admin at
  boot, so there is no first-run create-admin step. Login: `POST /api/v1/auth/login` → session cookie; `/api/v1/*`
  needs it (401 without).
- **`RAILWAY_RUN_UID=0`.** The image runs as non-root `bun`; Railway mounts volumes as root, so this lets the
  process write `/data`.
- **`PORT` = 8787** = the domain target port; health check `/api/health`.
- **Brand.** "EdgeEver" and its logo are the project's marks and are not covered by the AGPL. The template states
  only that it is based on EdgeEver, does not use the logo, and does not imply official status.
- **The marketplace OVERVIEW needs `### Deployment Dependencies` as an H3** or Railway's publish rejects the readme.
