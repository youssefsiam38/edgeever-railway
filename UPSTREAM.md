# Upstream and pinned versions

This template runs **EdgeEver** (the upstream project by tianma-if) from its official self-hosted image, pinned by
digest. There is no wrapper image — the application is used unmodified and configured through environment variables.

## EdgeEver

- Project: https://github.com/tianma-if/edgeever
- Licence: AGPL-3.0 (`licenses/EDGEEVER-LICENSE`)
- Official image: `ghcr.io/tianma-if/edgeever`
- Pinned: `ghcr.io/tianma-if/edgeever:1.40.0`
  - digest `sha256:611ad6813dbf456bfc2e2fb714c6c21b19ef6852daab5d491716e5c82ded9c50`

## Refreshing a digest

```bash
docker buildx imagetools inspect ghcr.io/tianma-if/edgeever:<tag> --format '{{json .Manifest}}' | jq -r .digest
```

Update the pins here, in `compose.yaml`, and in `_audit/spec_edgeever.py`, then re-run the tests and re-point the
template at the new tag. See `MAINTENANCE.md`.
