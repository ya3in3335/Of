# OUTIFOR

**Customer directory and delivery locations for a wholesale business** (OutiFor — Quincaillerie & Outillage).

An employee holding a paper invoice types the customer's name, picks the right
match, and calls, opens WhatsApp, or starts Google Maps navigation. The
administrator manages customers, exact GPS locations and staff accounts.
OUTIFOR is not an e-commerce, order or stock system.

| | |
|---|---|
| App | Flutter (Android), Riverpod, go_router, flutter_map |
| Backend | Supabase: PostgreSQL + Row Level Security, Auth, Realtime, Edge Function |
| Languages | Arabic (RTL), French, English |

## Features

**Employees (livreurs)**: search-first home screen with results as you type
(partial names, any order, Arabic and Latin spelling variants, phone numbers,
`OUT-000125` references). Similar names are always listed with phone, reference
and city; nothing opens automatically. The customer profile has Call,
WhatsApp, Route (Google Maps), Copy phone and Copy reference. There is also a
customer map with clusters and the user's own position, a notifications feed
of directory changes, and offline search on the synced copy.

**Administrators**: dashboard (statistics, recent customers, recent activity,
quick actions). Add, edit, archive, restore and delete customers. Exact
location picker (pan or tap the map, address search, GPS, manual
coordinates, preview before saving). Extra delivery addresses and private
admin notes. Duplicate detection while typing and on save, plus a duplicate
review screen (never an automatic merge). Staff accounts: create, activate or
deactivate, reset the password, change the role, see the last login. Activity
log and company settings.

**Security**: permissions are enforced by PostgreSQL RLS, not by hiding
buttons. A deactivated account loses access on its next request. There is no
public sign-up, and the service-role key never ships in the app. See
[docs/SECURITY.md](docs/SECURITY.md).

## Documentation

* [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): architecture, data model, permissions, navigation, sync
* [docs/SETUP.md](docs/SETUP.md): Supabase setup, first admin, APK build and signing
* [docs/SECURITY.md](docs/SECURITY.md): threat model and what was verified

## Quick start

```bash
supabase link --project-ref <ref> && supabase db push && supabase functions deploy admin-users
cp env/example.json env/prod.json   # fill in URL + publishable key
flutter build apk --release --dart-define-from-file=env/prod.json
```

## Tests

```bash
flutter analyze && flutter test     # 100 unit + widget tests
scripts/test_db.sh                  # 83 database permission/behaviour checks (PostgreSQL)
```

## Project layout

```
lib/core        config, theme (design tokens), router + role guard, utils, l10n helpers
lib/data        models, Supabase repositories, device cache, launcher/geo services
lib/domain      search engine, delta-sync merge, directory controller
lib/features    auth, dashboard, search, customers, maps, employees, settings, notifications
lib/shared      reusable widgets (buttons, states, skeletons, dialogs, sync badge)
lib/l10n        app_ar.arb, app_fr.arb, app_en.arb
supabase        migrations, Edge Function, SQL tests, admin bootstrap
```
