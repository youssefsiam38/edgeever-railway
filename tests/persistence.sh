#!/usr/bin/env bash
# shellcheck disable=SC2015
# Persistence: notebooks, memos and the admin account live in SQLite on the /data volume. Create a notebook, take
# the stack down keeping the volume, bring it back, and confirm the notebook survived. Standalone.
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"
trap 'compose logs --no-color --tail 100 || true; compose down -v --remove-orphans >/dev/null 2>&1 || true; rm -rf "$TEST_TMP"' EXIT

section "bring the stack up"
compose up -d --pull always >/dev/null 2>&1 || die "compose up failed"
wait_for_code "$APP_URL/api/health" 200 180 || die "app never became healthy"

section "before restart"
jar="$TEST_TMP/jar"
login "$jar" || die "admin login failed"
marker="persist-notebook-$(date +%s)"
resp=$(curl -s -b "$jar" --max-time 30 -X POST "$APP_URL/api/v1/notebooks" -H 'Content-Type: application/json' \
  --data "$(jq -nc --arg n "$marker" '{name:$n}')")
assert_contains "a notebook is created" "$marker" "$resp"
assert_contains "the notebook lists back" "$marker" "$(auth_get "$jar" /api/v1/notebooks)"

section "full restart (volume preserved)"
compose down >/dev/null 2>&1
compose up -d >/dev/null 2>&1 || die "compose up failed"
wait_for_code "$APP_URL/api/health" 200 180 && pass "healthy again after restart" || die "not healthy after restart"

section "after restart"
jar2="$TEST_TMP/jar2"
login "$jar2" || die "admin login failed after restart"
assert_contains "the notebook survived the restart (SQLite persisted)" "$marker" "$(auth_get "$jar2" /api/v1/notebooks)"

summary
