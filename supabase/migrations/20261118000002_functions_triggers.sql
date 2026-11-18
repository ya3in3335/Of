-- OUTIFOR — helper functions, triggers, RPCs

-- ---------------------------------------------------------------------------
-- Role helpers. SECURITY DEFINER so RLS policies can read profiles without
-- recursion; they always look at the live profile row, so deactivation and
-- role changes apply on the very next request.
-- ---------------------------------------------------------------------------

create or replace function public.is_active_user()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.is_active
  );
$$;

create or replace function public.is_active_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.is_active and p.role = 'admin'
  );
$$;

create or replace function public.assert_active_admin()
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_active_admin() then
    raise exception 'Administrator privileges required' using errcode = '42501';
  end if;
end;
$$;

-- True when the current statement runs with the service role (Edge Functions)
-- or as a database owner (migrations, SQL editor).
create or replace function public.is_privileged_session()
returns boolean
language sql
stable
set search_path = ''
as $$
  select current_user in ('service_role', 'postgres', 'supabase_admin')
      or coalesce(current_setting('request.jwt.claims', true)::jsonb ->> 'role', '') = 'service_role';
$$;

-- ---------------------------------------------------------------------------
-- Generic updated_at trigger
-- ---------------------------------------------------------------------------

create or replace function public.tg_set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Auth -> profiles
-- A profile is only active when the account was provisioned by the
-- admin-users Edge Function (app_metadata.outifor_provisioned = true).
-- app_metadata cannot be set by end users, so even if public sign-up were
-- enabled by mistake, a self-registered account would have no data access.
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta      jsonb := coalesce(new.raw_app_meta_data, '{}'::jsonb);
  umeta     jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_username text;
  v_role     text;
begin
  v_username := lower(coalesce(nullif(meta ->> 'username', ''), split_part(coalesce(new.email, new.id::text), '@', 1)));
  v_username := regexp_replace(v_username, '[^a-z0-9._-]', '', 'g');
  if char_length(v_username) < 3 then
    v_username := 'user' || substr(replace(new.id::text, '-', ''), 1, 8);
  end if;
  -- Avoid unique violations on an imported or legacy account
  if exists (select 1 from public.profiles where lower(username) = v_username) then
    v_username := left(v_username, 23) || '-' || substr(replace(new.id::text, '-', ''), 1, 8);
  end if;

  v_role := case when meta ->> 'role' = 'admin' then 'admin' else 'employee' end;

  insert into public.profiles (id, full_name, username, role, is_active, created_by)
  values (
    new.id,
    coalesce(nullif(btrim(umeta ->> 'full_name'), ''), nullif(btrim(meta ->> 'full_name'), ''), v_username),
    v_username,
    v_role,
    coalesce((meta ->> 'outifor_provisioned')::boolean, false),
    nullif(meta ->> 'created_by', '')::uuid
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

create or replace function public.handle_auth_user_login()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.last_sign_in_at is distinct from old.last_sign_in_at then
    update public.profiles set last_login_at = new.last_sign_in_at where id = new.id;
  end if;
  return new;
end;
$$;

create trigger on_auth_user_login
  after update of last_sign_in_at on auth.users
  for each row execute function public.handle_auth_user_login();

-- ---------------------------------------------------------------------------
-- Profile guards: nobody changes their own role or active flag, only admins or
-- the service role change anyone's, and the last active admin stays an active admin.
-- ---------------------------------------------------------------------------

create or replace function public.tg_profiles_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    new.id := old.id;
    new.created_at := old.created_at;
    new.created_by := old.created_by;

    if (new.role is distinct from old.role or new.is_active is distinct from old.is_active
        or new.username is distinct from old.username) then
      if not public.is_privileged_session() then
        if not public.is_active_admin() then
          raise exception 'Only administrators can change roles, usernames or account status'
            using errcode = '42501';
        end if;
        if old.id = auth.uid() then
          raise exception 'You cannot change your own role or account status' using errcode = '42501';
        end if;
      end if;
    end if;

    if not public.is_privileged_session() and new.last_login_at is distinct from old.last_login_at then
      new.last_login_at := old.last_login_at;
    end if;

    if old.role = 'admin' and old.is_active and (new.role <> 'admin' or not new.is_active) then
      if not exists (
        select 1 from public.profiles
        where role = 'admin' and is_active and id <> old.id
      ) then
        raise exception 'The last active administrator cannot be demoted or deactivated'
          using errcode = 'P0001';
      end if;
    end if;
  end if;
  return new;
end;
$$;

create trigger profiles_guard
  before update on public.profiles
  for each row execute function public.tg_profiles_guard();

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.tg_set_updated_at();

-- ---------------------------------------------------------------------------
-- Customers: normalisation, reference, search keys, audit
-- ---------------------------------------------------------------------------

create or replace function public.tg_customers_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.first_name      := btrim(regexp_replace(new.first_name, '\s+', ' ', 'g'));
  new.last_name       := btrim(regexp_replace(new.last_name, '\s+', ' ', 'g'));
  new.business_name   := nullif(btrim(regexp_replace(coalesce(new.business_name, ''), '\s+', ' ', 'g')), '');
  new.wilaya          := btrim(new.wilaya);
  new.commune         := btrim(new.commune);
  new.address         := btrim(new.address);
  new.primary_phone   := public.normalize_phone(new.primary_phone);
  new.secondary_phone := public.normalize_phone(new.secondary_phone);
  new.whatsapp_phone  := public.normalize_phone(new.whatsapp_phone);

  if tg_op = 'INSERT' then
    -- The reference is always generated server-side.
    new.reference  := 'OUT-' || lpad(nextval('public.customer_reference_seq')::text, 6, '0');
    new.created_at := now();
    new.created_by := auth.uid();
  else
    new.id         := old.id;
    new.reference  := old.reference;
    new.created_at := old.created_at;
    new.created_by := old.created_by;
  end if;

  new.updated_at := now();
  new.updated_by := auth.uid();
  new.name_key := public.normalize_search(new.first_name || ' ' || new.last_name);
  new.search_text := public.normalize_search(concat_ws(' ',
      new.first_name, new.last_name, new.business_name, new.reference,
      new.commune, new.wilaya))
    || ' ' || concat_ws(' ', new.primary_phone, new.secondary_phone, new.whatsapp_phone);
  return new;
end;
$$;

create trigger customers_before_write
  before insert or update on public.customers
  for each row execute function public.tg_customers_before_write();

create or replace function public.tg_customers_audit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_action text;
  v_details jsonb;
begin
  if tg_op = 'INSERT' then
    insert into public.activity_logs (actor_id, action, customer_id, details)
    values (auth.uid(), 'customer_created', new.id,
            jsonb_build_object('reference', new.reference, 'name', new.first_name || ' ' || new.last_name));
    return new;
  elsif tg_op = 'UPDATE' then
    if new.status <> old.status then
      v_action := case when new.status = 'archived' then 'customer_archived' else 'customer_restored' end;
    elsif (new.latitude, new.longitude) is distinct from (old.latitude, old.longitude)
          and (new.first_name, new.last_name, new.primary_phone, new.address)
              is not distinct from (old.first_name, old.last_name, old.primary_phone, old.address) then
      v_action := 'customer_location_updated';
    else
      v_action := 'customer_updated';
    end if;
    select coalesce(jsonb_agg(key), '[]'::jsonb) into v_details
    from jsonb_each(to_jsonb(new)) n
    where key not in ('updated_at', 'updated_by', 'search_text', 'name_key')
      and n.value is distinct from (to_jsonb(old) -> key);
    if v_details = '[]'::jsonb then
      return new;  -- nothing meaningful changed (e.g. touch from an address edit)
    end if;
    insert into public.activity_logs (actor_id, action, customer_id, details)
    values (auth.uid(), v_action, new.id,
            jsonb_build_object('reference', new.reference,
                               'name', new.first_name || ' ' || new.last_name,
                               'fields', v_details));
    return new;
  else
    insert into public.customer_deletions (customer_id, reference, deleted_by)
    values (old.id, old.reference, auth.uid())
    on conflict (customer_id) do update set deleted_at = now(), deleted_by = excluded.deleted_by;
    insert into public.activity_logs (actor_id, action, customer_id, details)
    values (auth.uid(), 'customer_deleted', null,
            jsonb_build_object('reference', old.reference, 'name', old.first_name || ' ' || old.last_name,
                               'customer_id', old.id));
    return old;
  end if;
end;
$$;

create trigger customers_audit
  after insert or update or delete on public.customers
  for each row execute function public.tg_customers_audit();

-- Extra addresses and admin notes bump the parent customer so device caches
-- see the change during delta sync.
create or replace function public.tg_touch_parent_customer()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_customer uuid := coalesce(new.customer_id, old.customer_id);
begin
  if tg_op <> 'DELETE' then
    new.updated_at := now();
  end if;
  update public.customers set updated_at = now() where id = v_customer;
  return coalesce(new, old);
end;
$$;

create trigger customer_addresses_touch
  before insert or update or delete on public.customer_addresses
  for each row execute function public.tg_touch_parent_customer();

create or replace function public.tg_admin_notes_stamp()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();
  return new;
end;
$$;

create trigger customer_admin_notes_stamp
  before insert or update on public.customer_admin_notes
  for each row execute function public.tg_admin_notes_stamp();

create or replace function public.tg_app_settings_stamp()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.id := 1;
  new.updated_at := now();
  new.updated_by := auth.uid();
  insert into public.activity_logs (actor_id, action, details)
  values (auth.uid(), 'settings_updated', jsonb_build_object('company_name', new.company_name));
  return new;
end;
$$;

create trigger app_settings_stamp
  before update on public.app_settings
  for each row execute function public.tg_app_settings_stamp();

-- A deleted customer that is re-created never collides with its tombstone
-- (new id), but a restore of the same id (backup import) clears the tombstone.
create or replace function public.tg_customers_clear_tombstone()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.customer_deletions where customer_id = new.id;
  return new;
end;
$$;

create trigger customers_clear_tombstone
  after insert on public.customers
  for each row execute function public.tg_customers_clear_tombstone();

-- ---------------------------------------------------------------------------
-- RPCs
-- ---------------------------------------------------------------------------

-- Server-side search (SECURITY INVOKER: RLS applies). The app searches its
-- synced copy first; this is used before the first sync and by integrations.
create or replace function public.search_customers(
  p_query text,
  p_include_archived boolean default false,
  p_limit integer default 30
)
returns table (
  id uuid, reference text, first_name text, last_name text, business_name text,
  primary_phone text, whatsapp_phone text, wilaya text, commune text, status text,
  has_location boolean, score real
)
language plpgsql
stable
set search_path = ''
as $$
declare
  q       text := public.normalize_search(p_query);
  digits  text := regexp_replace(coalesce(p_query, ''), '[^0-9]', '', 'g');
  tokens  text[];
begin
  if q = '' then
    return;
  end if;
  tokens := regexp_split_to_array(q, ' ');
  -- Partial international numbers: "+213 555 12" -> "055512"
  if digits like '00213%' then
    digits := '0' || substr(digits, 6);
  elsif digits like '213%' then
    digits := '0' || substr(digits, 4);
  end if;
  return query
    select c.id, c.reference, c.first_name, c.last_name, c.business_name,
           c.primary_phone, c.whatsapp_phone, c.wilaya, c.commune, c.status,
           c.latitude is not null,
           greatest(
             extensions.similarity(c.name_key, q),
             case when c.reference ilike '%' || p_query || '%' then 1.0 else 0 end,
             case when length(digits) >= 4 and c.search_text like '%' || digits || '%' then 0.9 else 0 end
           )::real as score
    from public.customers c
    where (p_include_archived or c.status = 'active')
      and (
        (select bool_and(c.search_text like '%' || t || '%') from unnest(tokens) t)
        or extensions.similarity(c.name_key, q) > 0.35
        or (length(digits) >= 4 and c.search_text like '%' || digits || '%')
      )
    order by score desc, c.last_name, c.first_name
    limit least(greatest(p_limit, 1), 100);
end;
$$;

-- Potential duplicates for a customer being created or edited (admin only).
create or replace function public.find_customer_duplicates(
  p_first_name text,
  p_last_name text,
  p_phones text[] default '{}',
  p_exclude_id uuid default null
)
returns table (
  id uuid, reference text, first_name text, last_name text, primary_phone text,
  commune text, wilaya text, status text, reason text, score real
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_name   text := public.normalize_search(coalesce(p_first_name, '') || ' ' || coalesce(p_last_name, ''));
  v_rev    text := public.normalize_search(coalesce(p_last_name, '') || ' ' || coalesce(p_first_name, ''));
  v_phones text[];
begin
  perform public.assert_active_admin();
  select coalesce(array_agg(distinct public.normalize_phone(x)) filter (where public.normalize_phone(x) is not null), '{}')
    into v_phones from unnest(coalesce(p_phones, '{}')) x;

  return query
    select c.id, c.reference, c.first_name, c.last_name, c.primary_phone, c.commune, c.wilaya, c.status,
           case
             when array[c.primary_phone, c.secondary_phone, c.whatsapp_phone] && v_phones then 'phone'
             else 'name'
           end as reason,
           greatest(
             case when array[c.primary_phone, c.secondary_phone, c.whatsapp_phone] && v_phones then 1.0 else 0 end,
             extensions.similarity(c.name_key, v_name),
             extensions.similarity(c.name_key, v_rev)
           )::real as score
    from public.customers c
    where (p_exclude_id is null or c.id <> p_exclude_id)
      and (
        array[c.primary_phone, c.secondary_phone, c.whatsapp_phone] && v_phones
        or (v_name <> '' and (c.name_key = v_name or c.name_key = v_rev
            or extensions.similarity(c.name_key, v_name) >= 0.6
            or extensions.similarity(c.name_key, v_rev) >= 0.6))
      )
    order by score desc
    limit 10;
end;
$$;

-- All potential duplicate pairs for the review screen (admin only).
create or replace function public.list_potential_duplicates(p_limit integer default 100)
returns table (
  customer_a uuid, customer_b uuid, reason text, score real
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.assert_active_admin();
  return query
    with phones as (
      select c.id, p.phone
      from public.customers c
      cross join lateral unnest(array[c.primary_phone, c.secondary_phone, c.whatsapp_phone]) as p(phone)
      where p.phone is not null
    ),
    phone_pairs as (
      select distinct least(a.id, b.id) as ca, greatest(a.id, b.id) as cb, 'phone'::text as reason, 1.0::real as score
      from phones a join phones b on a.phone = b.phone and a.id < b.id
    ),
    name_pairs as (
      select a.id as ca, b.id as cb, 'name'::text as reason,
             extensions.similarity(a.name_key, b.name_key)::real as score
      from public.customers a
      join public.customers b on a.id < b.id
        and (a.name_key = b.name_key or extensions.similarity(a.name_key, b.name_key) >= 0.75)
    ),
    all_pairs as (
      select * from phone_pairs
      union all
      select * from name_pairs np
      where not exists (select 1 from phone_pairs pp where pp.ca = np.ca and pp.cb = np.cb)
    )
    select ap.ca, ap.cb, ap.reason, ap.score
    from all_pairs ap
    where not exists (
      select 1 from public.duplicate_dismissals d where d.customer_a = ap.ca and d.customer_b = ap.cb
    )
    order by ap.score desc
    limit least(greatest(p_limit, 1), 500);
end;
$$;

create or replace function public.dismiss_duplicate_pair(p_a uuid, p_b uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.assert_active_admin();
  if p_a = p_b then
    raise exception 'A customer cannot be its own duplicate';
  end if;
  insert into public.duplicate_dismissals (customer_a, customer_b, dismissed_by)
  values (least(p_a, p_b), greatest(p_a, p_b), auth.uid())
  on conflict do nothing;
  insert into public.activity_logs (actor_id, action, customer_id, details)
  values (auth.uid(), 'duplicate_dismissed', least(p_a, p_b),
          jsonb_build_object('customer_a', least(p_a, p_b), 'customer_b', greatest(p_a, p_b)));
end;
$$;

-- Employee field actions (view, call, WhatsApp, navigate). The actor is
-- always the caller, and only these actions are accepted.
create or replace function public.log_customer_action(p_action text, p_customer_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_active_user() then
    raise exception 'Account inactive or not authenticated' using errcode = '42501';
  end if;
  if p_action not in ('customer_viewed', 'customer_called', 'customer_whatsapp', 'customer_navigated') then
    raise exception 'Action not allowed: %', p_action using errcode = '22023';
  end if;
  if not exists (select 1 from public.customers where id = p_customer_id) then
    raise exception 'Unknown customer' using errcode = 'P0002';
  end if;
  -- Skip identical entries within one minute (double taps, re-opened screens).
  if exists (
    select 1 from public.activity_logs
    where actor_id = auth.uid() and action = p_action and customer_id = p_customer_id
      and created_at > now() - interval '1 minute'
  ) then
    return;
  end if;
  insert into public.activity_logs (actor_id, action, customer_id)
  values (auth.uid(), p_action, p_customer_id);
end;
$$;

create or replace function public.admin_dashboard_stats()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb;
begin
  perform public.assert_active_admin();
  select jsonb_build_object(
    'customers_total',     (select count(*) from public.customers),
    'customers_active',    (select count(*) from public.customers where status = 'active'),
    'customers_archived',  (select count(*) from public.customers where status = 'archived'),
    'customers_last_7d',   (select count(*) from public.customers where created_at > now() - interval '7 days'),
    'customers_last_30d',  (select count(*) from public.customers where created_at > now() - interval '30 days'),
    'customers_no_location', (select count(*) from public.customers where latitude is null and status = 'active'),
    'employees_total',     (select count(*) from public.profiles where role = 'employee'),
    'employees_active',    (select count(*) from public.profiles where role = 'employee' and is_active)
  ) into result;
  return result;
end;
$$;

-- Users may change their own display name and phone, nothing else.
create or replace function public.update_own_profile(p_full_name text, p_phone text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_active_user() then
    raise exception 'Account inactive or not authenticated' using errcode = '42501';
  end if;
  update public.profiles
     set full_name = btrim(p_full_name),
         phone = public.normalize_phone(p_phone)
   where id = auth.uid();
end;
$$;

-- Used by the app at start-up and on resume: returns the caller's profile
-- only if it is active. An empty result means "sign out and wipe the cache".
create or replace function public.current_profile()
returns setof public.profiles
language sql
stable
security definer
set search_path = ''
as $$
  select * from public.profiles where id = auth.uid() and is_active;
$$;
