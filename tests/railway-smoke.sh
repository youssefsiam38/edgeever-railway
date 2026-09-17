#!/usr/bin/env bash
# shellcheck disable=SC2015
# Live test of a deployed template: the flows the local smoke covers, over HTTPS.
#
#   ADMIN_PASSWORD_FILE=./admin-password tests/railway-smoke.sh https://<app-domain>
#
# Optional: EDGEEVER_USERNAME (default admin). The password is read from a file (never an argument, never printed).
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
[ $# -ge 1 ] || { sed -n '3,6p' "$0"; exit 2; }
APP_URL=${1%/}; export APP_URL
: "${ADMIN_PASSWORD_FILE:?set ADMIN_PASSWORD_FILE}"
EDGEEVER_PASSWORD=$(tr -d '\n' < "$ADMIN_PASSWORD_FILE"); export EDGEEVER_PASSWORD
: "${EDGEEVER_USERNAME:=admin}"; export EDGEEVER_USERNAME
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"
trap 'rm -rf "$TEST_TMP"' EXIT

section "availability over HTTPS"
wait_for_code "$APP_URL/api/health" 200 300 && pass "/api/health returns 200 over HTTPS" || die "not healthy"
assert_eq "the web app is served at /" "200" "$(http_code "$APP_URL/")"

section "the API requires the admin login over HTTPS"
assert_eq "GET /api/v1/memos without a session is rejected" "401" "$(http_code "$APP_URL/api/v1/memos")"
assert_eq "a wrong password is rejected" "401" \
  "$(http_code -X POST "$APP_URL/api/v1/auth/login" -H 'Content-Type: application/json' --data '{"username":"admin","password":"definitely-wrong"}')"

section "the admin can log in and use the API over HTTPS"
jar="$TEST_TMP/jar"
login "$jar" && pass "the admin logs in with EDGE_EVER_AUTH_PASSWORD" || die "admin login failed"
assert_eq "GET /api/v1/memos works with the session" "200" "$(http_code -b "$jar" "$APP_URL/api/v1/memos")"
assert_contains "the default notebook exists" "nb_inbox" "$(auth_get "$jar" /api/v1/notebooks)"

summary
