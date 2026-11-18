-- OUTIFOR — core schema
-- Customer directory and location system for a wholesale business.
-- Target: Supabase (PostgreSQL 15+). Extensions live in the `extensions` schema, as on Supabase.

create schema if not exists extensions;
create extension if not exists pg_trgm with schema extensions;
create extension if not exists unaccent with schema extensions;

-- ---------------------------------------------------------------------------
-- Text normalisation (kept in sync with lib/core/utils/text_normalizer.dart)
-- ---------------------------------------------------------------------------

-- Folds case, Latin accents, Arabic letter variants, Arabic-Indic digits,
-- tashkeel and tatweel, then collapses repeated letters ("Mohammed" -> "mohamed")
-- and punctuation. Used for the search index and duplicate detection.
create or replace function public.normalize_search(input text)
returns text
language plpgsql
immutable
parallel safe
set search_path = ''
as $$
declare
  s text := coalesce(input, '');
begin
  s := lower(extensions.unaccent('extensions.unaccent'::regdictionary, s));
  -- Arabic diacritics (U+064B..U+0652), superscript alef (U+0670), tatweel (U+0640)
  s := regexp_replace(s, '[' || chr(1611) || '-' || chr(1618) || chr(1648) || chr(1600) || ']', '', 'g');
  -- Alef variants -> alef, alef maqsura -> ya, ta marbuta -> ha, hamza carriers
  s := translate(s,
        chr(1571) || chr(1573) || chr(1570) || chr(1649) || chr(1609) || chr(1577) || chr(1572) || chr(1574),
        chr(1575) || chr(1575) || chr(1575) || chr(1575) || chr(1610) || chr(1607) || chr(1608) || chr(1610));
  -- Arabic-Indic and Persian digits -> ASCII digits
  s := translate(s,
        chr(1632)||chr(1633)||chr(1634)||chr(1635)||chr(1636)||chr(1637)||chr(1638)||chr(1639)||chr(1640)||chr(1641)||
        chr(1776)||chr(1777)||chr(1778)||chr(1779)||chr(1780)||chr(1781)||chr(1782)||chr(1783)||chr(1784)||chr(1785),
        '01234567890123456789');
  -- Anything that is not a letter or digit becomes a space
  s := regexp_replace(s, '[^[:alnum:]' || chr(1536) || '-' || chr(1791) || ']+', ' ', 'g');
  -- Collapse doubled letters (not digits: phone numbers must stay intact)
  s := regexp_replace(s, '([a-z' || chr(1569) || '-' || chr(1610) || '])\1+', '\1', 'g');
  return btrim(regexp_replace(s, '\s+', ' ', 'g'));
end;
$$;

-- Canonical phone form: digits only, Algerian +213 / 00213 prefixes mapped to a leading 0.
create or replace function public.normalize_phone(input text)
returns text
language plpgsql
immutable
parallel safe
set search_path = ''
as $$
declare
  d text;
begin
  if input is null then
    return null;
  end if;
  d := translate(input,
        chr(1632)||chr(1633)||chr(1634)||chr(1635)||chr(1636)||chr(1637)||chr(1638)||chr(1639)||chr(1640)||chr(1641),
        '0123456789');
  d := regexp_replace(d, '[^0-9]', '', 'g');
  if d = '' then
    return null;
  end if;
  if d like '00213%' then
    d := '0' || substr(d, 6);
  elsif d like '213%' and length(d) >= 11 then
    d := '0' || substr(d, 4);
  end if;
  return d;
end;
$$;

-- ---------------------------------------------------------------------------
-- Profiles (one per auth user)
-- ---------------------------------------------------------------------------

create table public.profiles (
  id             uuid primary key references auth.users (id) on delete cascade,
  full_name      text not null check (char_length(btrim(full_name)) between 2 and 120),
  username       text not null check (username ~ '^[a-z0-9][a-z0-9._-]{2,31}$'),
  role           text not null default 'employee' check (role in ('admin', 'employee')),
  is_active      boolean not null default false,
  phone          text check (phone is null or phone ~ '^[0-9]{8,15}$'),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  last_login_at  timestamptz,
  created_by     uuid references public.profiles (id) on delete set null
);

create unique index profiles_username_key on public.profiles (lower(username));
create index profiles_role_active_idx on public.profiles (role, is_active);

comment on column public.profiles.is_active is
  'Inactive users lose all data access immediately (checked by RLS on every request).';

-- ---------------------------------------------------------------------------
-- Customers
-- ---------------------------------------------------------------------------

create sequence public.customer_reference_seq start 1;

create table public.customers (
  id               uuid primary key default gen_random_uuid(),
  reference        text not null unique,
  first_name       text not null check (char_length(btrim(first_name)) between 1 and 80),
  last_name        text not null check (char_length(btrim(last_name)) between 1 and 80),
  business_name    text check (business_name is null or char_length(business_name) <= 120),
  primary_phone    text not null check (primary_phone ~ '^[0-9]{8,15}$'),
  secondary_phone  text check (secondary_phone is null or secondary_phone ~ '^[0-9]{8,15}$'),
  whatsapp_phone   text check (whatsapp_phone is null or whatsapp_phone ~ '^[0-9]{8,15}$'),
  wilaya           text not null check (char_length(btrim(wilaya)) between 2 and 60),
  commune          text not null check (char_length(btrim(commune)) between 2 and 80),
  address          text not null check (char_length(btrim(address)) between 3 and 300),
  latitude         double precision check (latitude between -90 and 90),
  longitude        double precision check (longitude between -180 and 180),
  status           text not null default 'active' check (status in ('active', 'archived')),
  search_text      text not null default '',
  name_key         text not null default '',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  created_by       uuid references public.profiles (id) on delete set null,
  updated_by       uuid references public.profiles (id) on delete set null,
  constraint customers_coordinates_pair check ((latitude is null) = (longitude is null))
);

comment on table public.customers is
  'Customer directory. Primary address and phones live here; extra addresses in customer_addresses.';

create index customers_updated_at_idx on public.customers (updated_at);
create index customers_status_idx on public.customers (status);
create index customers_created_at_idx on public.customers (created_at desc);
create index customers_search_trgm_idx on public.customers using gin (search_text extensions.gin_trgm_ops);
create index customers_name_key_trgm_idx on public.customers using gin (name_key extensions.gin_trgm_ops);
create index customers_primary_phone_idx on public.customers (primary_phone);
create index customers_secondary_phone_idx on public.customers (secondary_phone) where secondary_phone is not null;
create index customers_whatsapp_phone_idx on public.customers (whatsapp_phone) where whatsapp_phone is not null;

-- Admin-only notes: separate table because RLS is row-level, not column-level.
create table public.customer_admin_notes (
  customer_id  uuid primary key references public.customers (id) on delete cascade,
  notes        text not null default '' check (char_length(notes) <= 4000),
  updated_at   timestamptz not null default now(),
  updated_by   uuid references public.profiles (id) on delete set null
);

-- Additional delivery addresses (the primary one is on customers).
create table public.customer_addresses (
  id           uuid primary key default gen_random_uuid(),
  customer_id  uuid not null references public.customers (id) on delete cascade,
  label        text not null check (char_length(btrim(label)) between 1 and 60),
  address      text not null check (char_length(btrim(address)) between 3 and 300),
  wilaya       text check (wilaya is null or char_length(wilaya) <= 60),
  commune      text check (commune is null or char_length(commune) <= 80),
  latitude     double precision check (latitude between -90 and 90),
  longitude    double precision check (longitude between -180 and 180),
  is_primary   boolean not null default false,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  constraint customer_addresses_coordinates_pair check ((latitude is null) = (longitude is null))
);

create index customer_addresses_customer_idx on public.customer_addresses (customer_id);

-- Tombstones so device caches can apply deletions during delta sync.
create table public.customer_deletions (
  customer_id  uuid primary key,
  reference    text not null,
  deleted_at   timestamptz not null default now(),
  deleted_by   uuid references public.profiles (id) on delete set null
);

create index customer_deletions_deleted_at_idx on public.customer_deletions (deleted_at);

-- Pairs an admin reviewed and marked as "not a duplicate". customer_a < customer_b.
create table public.duplicate_dismissals (
  customer_a    uuid not null references public.customers (id) on delete cascade,
  customer_b    uuid not null references public.customers (id) on delete cascade,
  dismissed_at  timestamptz not null default now(),
  dismissed_by  uuid references public.profiles (id) on delete set null,
  primary key (customer_a, customer_b),
  check (customer_a < customer_b)
);

-- ---------------------------------------------------------------------------
-- Activity log (admin and employee actions). Written only by triggers and
-- security-definer functions; clients have no INSERT privilege.
-- ---------------------------------------------------------------------------

create table public.activity_logs (
  id                 bigint generated always as identity primary key,
  actor_id           uuid references public.profiles (id) on delete set null,
  action             text not null check (action in (
                       'customer_created', 'customer_updated', 'customer_location_updated',
                       'customer_archived', 'customer_restored', 'customer_deleted',
                       'customer_viewed', 'customer_called', 'customer_whatsapp', 'customer_navigated',
                       'employee_created', 'employee_activated', 'employee_deactivated',
                       'employee_password_reset', 'employee_updated',
                       'duplicate_dismissed', 'settings_updated')),
  customer_id        uuid references public.customers (id) on delete set null,
  target_profile_id  uuid references public.profiles (id) on delete set null,
  details            jsonb not null default '{}'::jsonb,
  created_at         timestamptz not null default now()
);

create index activity_logs_created_at_idx on public.activity_logs (created_at desc);
create index activity_logs_actor_idx on public.activity_logs (actor_id, created_at desc);
create index activity_logs_customer_idx on public.activity_logs (customer_id, created_at desc);

-- ---------------------------------------------------------------------------
-- App settings (single row)
-- ---------------------------------------------------------------------------

create table public.app_settings (
  id              smallint primary key default 1 check (id = 1),
  company_name    text not null default 'OUTIFOR' check (char_length(btrim(company_name)) between 2 and 80),
  default_latitude   double precision not null default 36.7538 check (default_latitude between -90 and 90),
  default_longitude  double precision not null default 3.0588 check (default_longitude between -180 and 180),
  default_zoom       double precision not null default 11 check (default_zoom between 3 and 19),
  updated_at      timestamptz not null default now(),
  updated_by      uuid references public.profiles (id) on delete set null
);

insert into public.app_settings (id) values (1);
