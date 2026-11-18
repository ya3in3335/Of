# OUTIFOR — Security model and verification (Phase 5)

## Threat model

| Threat | Control |
|---|---|
| Employee edits or deletes customers through the raw REST API | RLS: `INSERT/UPDATE/DELETE` on `customers`, `customer_addresses` and `customer_admin_notes` require `is_active_admin()`. Column grants also stop clients from writing `reference`, `created_by` and `search_text`. |
| Employee reads admin notes | Notes live in `customer_admin_notes`, which only admins can access (RLS is per row, so a column would have leaked). |
| Employee promotes themselves | `profiles` UPDATE is allowed for admins only. The `profiles_guard` trigger also blocks role, status and username changes by non-admins, and stops anyone from changing their *own* role or status. |
| Deactivated employee keeps using a valid JWT | Every policy calls `is_active_user()` / `is_active_admin()`, which read the live `profiles` row, so access ends on the next request. The Edge Function also bans the auth user, which stops token refresh. |
| Last admin locked out | The trigger refuses to demote or deactivate the last active admin, even through the service role. |
| Public self-registration | Sign-up is disabled. If it is enabled by mistake, the profile still starts inactive, because only `app_metadata.outifor_provisioned` (settable by the service role only) activates it. `user_metadata` claims are ignored. |
| Service-role key leakage | The key exists only in the `admin-users` Edge Function. That function checks that the caller's JWT belongs to an **active admin** (read from `profiles`, not from the request body) before doing anything. |
| Forged audit entries | Clients have no `INSERT` on `activity_logs`. Entries come from triggers or `log_customer_action`, which only accepts 4 field actions and always records the caller as the actor. |
| Lost update between two admins | `save_customer` takes the `updated_at` the form was opened with and refuses the save if the record changed meanwhile (`40001`). |
| SQL injection | Only PostgREST parameterised queries and typed RPC arguments are used. The SQL functions use `set search_path = ''` and never build dynamic SQL. |
| Data on lost phones | The cache is stored in app-private storage, excluded from Android backup and device transfer (`data_extraction_rules.xml`), and erased on sign-out or deactivation. It never contains admin notes. |
| Passwords | Stored only by Supabase Auth (bcrypt). The app never stores passwords. Temporary passwords come from `Random.secure()` and are shown once. |
| Location privacy | Location permission is requested only when the user taps "My location". The employee's position is never sent to the server. |

## Verification performed

`scripts/test_db.sh` applies the real migrations to PostgreSQL 16 (with a
minimal stand-in for Supabase's `auth` schema and roles) and runs
`supabase/tests/rls_and_behaviour_test.sql`. The suite **passes all 83 checks**.
They include:

* anonymous callers cannot read customers, profiles or call RPCs;
* an employee can read the directory and search, but cannot insert, update or
  delete customers, addresses or notes, cannot read admin notes or the
  activity log, cannot forge logs, cannot call admin RPCs or `save_customer`,
  cannot change settings, and cannot promote themselves or write `last_login_at`;
* a self-registered (unprovisioned) account reads nothing, even though its
  user metadata claims `admin`;
* a deactivated employee immediately reads nothing and cannot log actions;
* an admin cannot deactivate or demote themselves, and the service role cannot
  demote the last admin;
* references are generated on the server and cannot be changed; phones are
  normalised; constraints reject bad coordinates and phones;
* search covers partial names, reversed names, Arabic with and without
  diacritics, references, partial and international phone numbers, and
  archived customers being excluded;
* duplicate detection finds the same phone and similar or swapped names, never
  merges records, and dismissed pairs disappear from review;
* deletes write sync tombstones and audit entries; address edits bump
  `updated_at` for delta sync; optimistic concurrency rejects stale saves.

Not covered by automated tests here: the Edge Function against a live Supabase
project (it is type-checked with `deno check`), and Realtime delivery. Test
both on a staging project before going live. The checklist is below.

## Manual acceptance checklist on a staging project

1. Admin signs in, creates an employee (shown credentials work), creates a customer with GPS.
2. Employee phone: the customer appears without a manual refresh (Realtime), and search finds it.
3. Employee: Call, WhatsApp and Route open the dialer, WhatsApp and Google Maps.
4. With the employee's JWT, `curl -X PATCH …/rest/v1/customers?id=eq.<id> -d '{"first_name":"x"}'` returns an empty array, and the row is unchanged.
5. Admin deactivates the employee: within seconds the employee's phone returns to the login screen with the "deactivated" message.
6. Airplane mode on the employee phone: search still works, and the banner says offline. Admin save while offline shows "Nothing was saved".
