# OUTIFOR — Architecture (Phase 1)

OUTIFOR is the internal customer directory and location system for a wholesale
business (grossiste). It does one job: someone holding a paper invoice gets from
a customer name to a phone call or a navigation route in a few seconds.

## 1. Technology choices

| Concern | Choice | Why |
|---|---|---|
| Mobile app | **Flutter 3.x** (Android first) | Requested. One codebase, good performance on mid-range Android, strong RTL support. |
| State management | **Riverpod 2** | Testable, compile-safe dependency injection; keeps the data layer swappable in tests. |
| Routing | **go_router** | Declarative routes with role-based redirects (an employee cannot even reach an admin route). |
| Backend | **Supabase**: Postgres, Auth, Realtime, Edge Functions | Requested. All permissions live in Postgres RLS, so they hold even for direct API calls. |
| Maps | **flutter_map + OpenStreetMap tiles** (tile URL configurable) | No API key or billing account is needed to ship, and the tile server can be swapped for MapTiler or Mapbox later with one setting. Navigation still opens **Google Maps**, as requested. Address search uses Nominatim (OSM). |
| Local cache | JSON snapshot on the device + delta sync | Search is instant and still works with poor coverage; see §6. |
| i18n | Flutter `gen-l10n`: **Arabic (RTL), French, English** | Arabic text uses Cairo; Latin text uses Inter. Both fonts are bundled, so nothing is downloaded at runtime. |

Departures from the brief, and why:

* **Maps provider.** Google Maps SDK tiles need a billed API key before the app
  even starts. OSM tiles work immediately. External navigation is Google Maps.
* **`admin_notes`.** Notes are kept in a separate table, `customer_admin_notes`,
  that only admins can read. Postgres RLS works per row, not per column, so a
  notes column on `customers` would be readable by anyone allowed to read the
  row. With a separate table, employees cannot read the notes even through the
  raw REST API.
* **Activity logs.** The suggested `employee_activity_logs` table is generalised
  to `activity_logs`, which records both admin actions (customer created,
  updated, archived or deleted, employee created or deactivated…) and employee
  actions (viewed, called, WhatsApp, navigated). The rows are written by
  database triggers and security-definer functions, never by inserts from the
  client.

## 2. Layers and folders

```
lib/
  main.dart / app.dart          bootstrap, theme, router, localisation
  core/                         config, theme (design system), utils (normalisation,
                                phone, validators), l10n, errors, connectivity
  data/
    models/                     Customer, CustomerAddress, Profile, ActivityLog, AppSettings
    services/                   SupabaseService, LocalCacheService, GeocodingService, LauncherService
    repositories/               AuthRepository, CustomerRepository, EmployeeRepository,
                                ActivityRepository, SettingsRepository
  domain/                       CustomerSearchEngine (pure Dart, unit-tested), sync state
  features/
    auth/          splash, onboarding, login
    dashboard/     admin dashboard, employee home (search-first)
    customers/     directory, search, profile, add/edit form, duplicate review
    maps/          map overview, location picker, mini map preview
    employees/     list, add, details (activate, reset password)
    settings/      settings hub, account, profile, language, app settings, activity log
    notifications/ recent directory changes
  shared/widgets/  buttons, cards, skeletons, empty/error states, dialogs, sync badge
supabase/
  migrations/      schema, RLS, functions, triggers, realtime
  functions/admin-users/   Edge Function for account administration (service role stays server-side)
  tests/           SQL permission and behaviour tests (plain SQL, run with psql)
```

Presentation code (widgets) only talks to Riverpod providers. Providers call
repositories. Repositories are the only code that talks to Supabase or the
device cache.

## 3. Data model

```
auth.users 1─1 profiles (role: admin|employee, is_active, username, last_login_at)
customers  1─0..1 customer_admin_notes      (admin-only)
customers  1─n    customer_addresses        (extra delivery addresses; the primary address lives on customers)
customers  1─n    customer_deletions         (tombstones, so device caches can sync deletes)
activity_logs  n─1 profiles (actor), n─0..1 customers
duplicate_dismissals  (customer_a, customer_b): pairs an admin reviewed as "not a duplicate"
app_settings  (single row: company name, default map centre)
```

Key points:

* `customers.reference` is filled in by a trigger from a sequence
  (`OUT-000001`). Clients cannot choose or change it.
* `customers.search_text` is a generated, normalised string (case, accents and
  Arabic letter variants folded; phone digits reduced to their national form)
  with a trigram GIN index. The app uses the same normalisation in Dart.
* Extra phone numbers can be added later as a `customer_phones` table, the same
  way `customer_addresses` works, without changing existing tables.

## 4. Permissions (enforced in Postgres)

Helper functions: `is_active_user()`, `is_admin()`, `is_active_admin()`.
They are `SECURITY DEFINER` and read `profiles`, so deactivating an account
takes effect on the user's next request, even if their JWT is still valid.

| Table / action | Admin (active) | Employee (active) | Inactive / anonymous |
|---|---|---|---|
| customers SELECT | ✓ | ✓ | ✗ |
| customers INSERT/UPDATE/DELETE | ✓ | ✗ | ✗ |
| customer_admin_notes (any) | ✓ | ✗ | ✗ |
| customer_addresses SELECT / write | ✓ / ✓ | ✓ / ✗ | ✗ |
| profiles SELECT | all | own row | ✗ |
| profiles UPDATE | via Edge Function / RPC only | `update_own_profile(full_name)` only | ✗ |
| activity_logs SELECT | ✓ | ✗ | ✗ |
| activity_logs INSERT | trigger / `log_customer_action` | `log_customer_action` (whitelisted actions, own id) | ✗ |
| app_settings SELECT / UPDATE | ✓ / ✓ | ✓ / ✗ | ✗ |

Account administration (create a user, reset a password, activate or
deactivate) needs the Supabase service-role key. It runs in the `admin-users`
Edge Function, which checks that the caller is an active admin before doing
anything. The key is never in the app.

Guards: a user cannot change their own role or `is_active`; the last active
admin cannot be demoted or deactivated; there is no public sign-up (it must
be disabled in Auth settings, see `docs/SETUP.md`).

## 5. Navigation

```
Splash ─► Onboarding (first launch) ─► Login ─► role shell
Admin shell (bottom nav + FAB "New customer")
  Dashboard │ Customers │ Employees │ Map │ Settings
Employee shell
  Search (home) │ Customers │ Map │ Profile
Pushed routes: customer/:id, customer/:id/edit, customer/new, customer/:id/location,
  duplicates, employees/new, employees/:id, settings/{account,profile,language,app,activity},
  notifications
```

## 6. Sync and offline

* After login, the app downloads the directory, then fetches only rows whose
  `updated_at` is newer than its cursor, plus tombstones from
  `customer_deletions`. Supabase Realtime triggers a delta sync when another
  device changes data, and so does a reconnect or the app coming back to the
  foreground.
* Search runs on the device's copy, so results appear while you type, even
  offline. A sync badge always shows the state: synced at HH:MM, syncing,
  offline (showing the copy from HH:MM), or error.
* Writes (admin) are **never queued**. When offline, saving shows a clear error.
  A change is reported as saved only after the server confirms it. The submit
  button stays disabled while a save is in flight, so it cannot be sent twice.
* Logging out, or the server reporting the account as inactive, wipes the
  device cache.

## 7. Screens (all functional)

1 Splash · 2 Onboarding · 3 Login · 4 Admin dashboard · 5 Employee home ·
6 Customer directory · 7 Smart search · 8 Search results (inline list with
distinguishing details) · 9 Customer profile · 10 Customer location map / map
overview · 11 Add customer · 12 Edit customer · 13 Employee directory ·
14 Add employee · 15 Employee details · 16 Account settings (password) ·
17 Profile settings · 18 Language · 19 Notifications (recent directory changes) ·
20 Error / empty / offline states (shared components used everywhere) ·
plus Duplicate review, Activity log, App settings (admin).
