#!/usr/bin/env bash
# Applies the OUTIFOR migrations to a throw-away PostgreSQL database (with a
# small Supabase stand-in) and runs the permission/behaviour tests.
#
# Usage: scripts/test_db.sh            (needs psql access as a superuser)
#        PGUSER=postgres PGHOST=localhost scripts/test_db.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB="${OUTIFOR_TEST_DB:-outifor_test}"
PSQL=(psql -X -v ON_ERROR_STOP=1 -q)

"${PSQL[@]}" -d postgres -c "drop database if exists ${DB};" >/dev/null
"${PSQL[@]}" -d postgres -c "create database ${DB};" >/dev/null

"${PSQL[@]}" -d "$DB" -f "$ROOT/supabase/tests/support/supabase_stub.sql" >/dev/null
for f in "$ROOT"/supabase/migrations/*.sql; do
  echo "applying $(basename "$f")"
  "${PSQL[@]}" -d "$DB" -f "$f" >/dev/null
done

"${PSQL[@]}" -t -A -d "$DB" -f "$ROOT/supabase/tests/rls_and_behaviour_test.sql" 2>&1 \
  | grep -v -e '^$' -e '^set_config' -e '^{' \
  | sed -e 's/^psql:[^ ]* NOTICE:  /  /' -e 's/^NOTICE:  /  /'

if [[ "${KEEP_DB:-0}" != "1" ]]; then
  "${PSQL[@]}" -d postgres -c "drop database ${DB};" >/dev/null
fi
