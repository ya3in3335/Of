#!/usr/bin/env bash
# Regenerates test/fixtures/normalization_cases.json from the SQL functions, so
# the Dart normaliser (lib/core/utils/text_normalizer.dart) is tested against
# the exact server behaviour. Requires a database built by scripts/test_db.sh
# with KEEP_DB=1.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB="${OUTIFOR_TEST_DB:-outifor_test}"
psql -X -q -t -A -d "$DB" <<'SQL' > "$ROOT/test/fixtures/normalization_cases.json"
with inputs(s) as (values
  ('  Mohamed   BENALI '), ('Mohammed'), ('Muhammad'), ('Hadj Aïssa'), ('Ammar Bouzid'),
  ('Quincaillerie El-Amel & Fils'), ('Société Générale d''Outillage'), ('Œuvre Ébéniste'),
  ('Ferhat Abbès'), ('Zoubir Laâmari'), ('Naïma Gaïd'), ('François Çelik'),
  ('مُحَمَّد'), ('محمد'), ('أحمد بن علي'), ('إبراهيم'), ('آمنة'), ('مصطفى'), ('فاطمة'), ('مؤسسة'), ('رئيس'),
  ('عبــد القادر'), ('الله'), ('OUT-000125'), ('out 125'), ('0555 12 34 56'), ('+213 555 12 34 56'),
  ('٠٥٥٥١٢٣٤٥٦'), ('Bab-Ezzouar'), ('Bir El Djir / Oran'), ('Tizi-Ouzou'), ('Aïn Témouchent'),
  ('Ghardaïa'), ('Béjaïa'), ('Rue des frères Abed, n°12'), (''), ('   '), ('Hello  World'), ('aaab'), ('SSS-111')
)
select jsonb_pretty(jsonb_build_object(
  'normalize_search', (select jsonb_agg(jsonb_build_array(s, public.normalize_search(s))) from inputs),
  'normalize_phone', (select jsonb_agg(jsonb_build_array(p, public.normalize_phone(p))) from (values
     ('0555 12 34 56'), ('+213 555 12 34 56'), ('00213555123456'), ('213555123456'), ('(021) 54-32-10'),
     ('٠٥٥٥١٢٣٤٥٦'), ('abc'), ('2130'), ('0770112233')) v(p))
));
SQL
echo "wrote test/fixtures/normalization_cases.json"
