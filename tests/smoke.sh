#!/usr/bin/env bash
# shellcheck disable=SC2015
# Smoke test: run the server, then verify liveness, that the app requires the admin login, and that an
# authenticated API call works.
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"

STARTED=0
if [ "${EDGEEVER_REUSE_STACK:-0}" != "1" ]; then
  section "bring the stack up"
  compose up -d --pull always >/dev/null 2>&1 || die "compose up failed"
  STARTED=1
  trap 'compose logs --no-color --tail 100 || true; [ "$STARTED" = 1 ] && compose down -v --remove-orphans >/dev/null 2>&1 || true; rm -rf "$TEST_TMP"' EXIT
else
  trap 'rm -rf "$TEST_TMP"' EXIT
fi

section "liveness"
wait_for_code "$APP_URL/api/health" 200 180 && pass "/api/health returns 200 (no auth)" || die "app never became healthy"
assert_eq "the web app is served at /" "200" "$(http_code "$APP_URL/")"

section "the API requires the admin login"
assert_eq "GET /api/v1/memos without a session is rejected" "401" "$(http_code "$APP_URL/api/v1/memos")"
assert_eq "a wrong password is rejected" "401" \
  "$(http_code -X POST "$APP_URL/api/v1/auth/login" -H 'Content-Type: application/json' --data '{"username":"admin","password":"definitely-wrong"}')"

section "the admin can log in and use the API"
jar="$TEST_TMP/jar"
login "$jar" && pass "the admin logs in with EDGE_EVER_AUTH_PASSWORD" || die "admin login failed"
assert_eq "GET /api/v1/memos works with the session" "200" "$(http_code -b "$jar" "$APP_URL/api/v1/memos")"
assert_contains "the default notebook exists" "nb_inbox" "$(auth_get "$jar" /api/v1/notebooks)"

summary
