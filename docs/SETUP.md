# OUTIFOR — Backend setup and APK build (Phase 7)

Follow these steps once. Allow about 30 minutes.

## 1. Create the Supabase project

1. Go to <https://supabase.com>, create a project, and pick the region closest to
   Algeria (for example `eu-central-1` Frankfurt).
2. In **Project Settings → API**, note:
   * the **Project URL** (`https://xxxx.supabase.co`)
   * the **publishable key** (or the legacy **anon** key). This key is public
     and goes in the app.
   * the **service_role / secret key**. **Never** put this key in the app or
     in git. Supabase gives it to the Edge Function automatically.

## 2. Apply the database migrations

With the [Supabase CLI](https://supabase.com/docs/guides/cli):

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push            # applies supabase/migrations/*.sql in order
```

Without the CLI, paste the four files from `supabase/migrations/` into
**SQL Editor**, in filename order, and run each one.

The migrations create the tables, indexes, triggers, Row Level Security
policies, the RPC functions, and the Realtime publication.

## 3. Lock down authentication

In **Authentication → Providers → Email**:

* turn **off** "Allow new users to sign up" (there is no public registration);
* turn **off** "Confirm email" (accounts are created already confirmed).

`supabase/config.toml` already has these values for CLI-managed projects. As
an extra safeguard, an account that was not created by an administrator gets
an *inactive* profile and cannot read any data, even if sign-up were left on.

## 4. Deploy the account-management Edge Function

```bash
supabase functions deploy admin-users
# Only if you change the login domain (must match LOGIN_DOMAIN in the app):
supabase secrets set OUTIFOR_LOGIN_DOMAIN=outifor.local
```

`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are injected by Supabase.

## 5. Create the first administrator

1. **Authentication → Users → Add user → Create new user**
   * Email: `directeur@outifor.local` (the username followed by `@` and the login domain)
   * Password: a strong password, and tick **Auto Confirm User**
2. Open `supabase/bootstrap_admin.sql`, set the email, username and name at
   the top, and run it in the **SQL Editor**.

The administrator signs in with the username `directeur` (or the full
email). Every other account is created from the app: **Employees → New employee**.

## 6. Configure and build the Android app

Requirements: Flutter 3.47 or newer (tested with 3.50.0), Android SDK 36, JDK 17+.

```bash
cp env/example.json env/prod.json     # env/*.json is git-ignored
# edit env/prod.json: SUPABASE_URL, SUPABASE_ANON_KEY (publishable key), LOGIN_DOMAIN
flutter pub get
flutter build apk --release --dart-define-from-file=env/prod.json
# → build/app/outputs/flutter-apk/app-release.apk
```

A build made without `--dart-define-from-file` starts on a "not configured"
screen. It never pretends to work.

### Release signing (required before distributing the APK)

```bash
keytool -genkey -v -keystore ~/outifor-release.jks -keyalg RSA -keysize 2048 \
        -validity 10000 -alias outifor
```

Create `android/key.properties` (git-ignored):

```properties
storePassword=...
keyPassword=...
keyAlias=outifor
storeFile=/home/you/outifor-release.jks
```

Without this file the release APK is signed with the debug key. That is fine
for testing on your own phones, but not for distribution. Keep the keystore
safe: if you lose it, you can no longer publish updates.

Smaller APKs, one per CPU type: `flutter build apk --release --split-per-abi --dart-define-from-file=env/prod.json`.

## 7. Optional configuration (`env/prod.json`)

| Key | Default | Purpose |
|---|---|---|
| `LOGIN_DOMAIN` | `outifor.local` | Usernames map to `username@LOGIN_DOMAIN`. Must match `OUTIFOR_LOGIN_DOMAIN`. |
| `MAP_TILE_URL` | OpenStreetMap | Tile server. With many users, use a commercial provider (MapTiler, Stadia…), because OSM's servers have a fair-use policy. |
| `MAP_TILE_ATTRIBUTION` | `© OpenStreetMap contributors` | Attribution shown on maps. |
| `GEOCODING_URL` | `https://nominatim.openstreetmap.org` | Address search (Nominatim API, max 1 request/s). |
| `GEOCODING_COUNTRIES` | `dz` | Countries searched. |

## 8. Run the tests

```bash
flutter analyze
flutter test                      # unit + widget tests
# Database permission tests (needs a local PostgreSQL 15+ with pg_trgm/unaccent, run as a superuser):
scripts/test_db.sh
```

## 9. Daily operation notes

* **Deactivating an employee** cuts off their server access immediately: RLS
  checks `is_active` on every request, and the auth account is banned. Their
  phone signs out and erases its cached copy at the next connection. A phone
  that stays offline keeps the copy it had already downloaded; that copy
  contains no administrator notes.
* **Backups:** Supabase takes daily backups on paid plans. Use
  `supabase db dump` for your own backups.
* **Push notifications** are not set up. The Notifications screen lists the
  directory changes the phone received through sync. Server push (FCM) can be
  added later without changing the data model.
