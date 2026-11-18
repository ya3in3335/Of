-- OUTIFOR — privileges and Row Level Security
-- Principle: deny by default. Anonymous callers get nothing. Authenticated
-- callers get rows only while their profile is active; writes to the
-- directory require an active admin.

alter table public.profiles             enable row level security;
alter table public.customers            enable row level security;
alter table public.customer_admin_notes enable row level security;
alter table public.customer_addresses   enable row level security;
alter table public.customer_deletions   enable row level security;
alter table public.duplicate_dismissals enable row level security;
alter table public.activity_logs        enable row level security;
alter table public.app_settings         enable row level security;

-- Supabase grants broad table privileges to anon/authenticated by default.
-- Narrow them so a policy mistake cannot widen access.
revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke all on all functions in schema public from anon, public;
alter default privileges in schema public revoke all on tables from anon, authenticated;
alter default privileges in schema public revoke all on functions from anon, public;

grant usage on schema public to authenticated;

-- The service role (Edge Functions only, never shipped in the app) keeps full access.
grant all on all tables in schema public to service_role;
grant all on all sequences in schema public to service_role;
grant execute on all functions in schema public to service_role;

grant select, update (full_name, phone, role, is_active, username) on public.profiles to authenticated;
grant select, insert, delete on public.customers to authenticated;
grant update (first_name, last_name, business_name, primary_phone, secondary_phone, whatsapp_phone,
              wilaya, commune, address, latitude, longitude, status) on public.customers to authenticated;
grant select, insert, update (notes), delete on public.customer_admin_notes to authenticated;
grant select, insert, update (label, address, wilaya, commune, latitude, longitude, is_primary), delete
  on public.customer_addresses to authenticated;
grant select on public.customer_deletions to authenticated;
grant select on public.duplicate_dismissals to authenticated;
grant select on public.activity_logs to authenticated;
grant select, update (company_name, default_latitude, default_longitude, default_zoom) on public.app_settings to authenticated;
grant usage on sequence public.customer_reference_seq to authenticated;

grant execute on function public.is_active_user()   to authenticated;
grant execute on function public.is_active_admin()  to authenticated;
grant execute on function public.is_privileged_session() to authenticated;
grant execute on function public.normalize_search(text) to authenticated;
grant execute on function public.normalize_phone(text)  to authenticated;
grant execute on function public.search_customers(text, boolean, integer) to authenticated;
grant execute on function public.find_customer_duplicates(text, text, text[], uuid) to authenticated;
grant execute on function public.list_potential_duplicates(integer) to authenticated;
grant execute on function public.dismiss_duplicate_pair(uuid, uuid) to authenticated;
grant execute on function public.log_customer_action(text, uuid) to authenticated;
grant execute on function public.admin_dashboard_stats() to authenticated;
grant execute on function public.update_own_profile(text, text) to authenticated;
grant execute on function public.current_profile() to authenticated;

-- Trigger and internal helpers must not be callable through the API.
revoke execute on function public.assert_active_admin() from authenticated;
revoke execute on function public.handle_new_auth_user() from authenticated;
revoke execute on function public.handle_auth_user_login() from authenticated;

-- ---------------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------------
create policy profiles_select_self on public.profiles
  for select to authenticated
  using (id = auth.uid());

create policy profiles_select_admin on public.profiles
  for select to authenticated
  using (public.is_active_admin());

create policy profiles_update_admin on public.profiles
  for update to authenticated
  using (public.is_active_admin())
  with check (public.is_active_admin());

-- No INSERT / DELETE policies: accounts are created and removed through the
-- admin-users Edge Function (service role), never by the app directly.

-- ---------------------------------------------------------------------------
-- customers
-- ---------------------------------------------------------------------------
create policy customers_select_active_users on public.customers
  for select to authenticated
  using (public.is_active_user());

create policy customers_insert_admin on public.customers
  for insert to authenticated
  with check (public.is_active_admin());

create policy customers_update_admin on public.customers
  for update to authenticated
  using (public.is_active_admin())
  with check (public.is_active_admin());

create policy customers_delete_admin on public.customers
  for delete to authenticated
  using (public.is_active_admin());

-- ---------------------------------------------------------------------------
-- customer_admin_notes (admin only, all operations)
-- ---------------------------------------------------------------------------
create policy admin_notes_all_admin on public.customer_admin_notes
  for all to authenticated
  using (public.is_active_admin())
  with check (public.is_active_admin());

-- ---------------------------------------------------------------------------
-- customer_addresses
-- ---------------------------------------------------------------------------
create policy addresses_select_active_users on public.customer_addresses
  for select to authenticated
  using (public.is_active_user());

create policy addresses_insert_admin on public.customer_addresses
  for insert to authenticated
  with check (public.is_active_admin());

create policy addresses_update_admin on public.customer_addresses
  for update to authenticated
  using (public.is_active_admin())
  with check (public.is_active_admin());

create policy addresses_delete_admin on public.customer_addresses
  for delete to authenticated
  using (public.is_active_admin());

-- ---------------------------------------------------------------------------
-- customer_deletions (tombstones, read-only for sync)
-- ---------------------------------------------------------------------------
create policy deletions_select_active_users on public.customer_deletions
  for select to authenticated
  using (public.is_active_user());

-- ---------------------------------------------------------------------------
-- duplicate_dismissals (admin read; written via dismiss_duplicate_pair)
-- ---------------------------------------------------------------------------
create policy dismissals_select_admin on public.duplicate_dismissals
  for select to authenticated
  using (public.is_active_admin());

-- ---------------------------------------------------------------------------
-- activity_logs (admin read; written by triggers and log_customer_action)
-- ---------------------------------------------------------------------------
create policy activity_select_admin on public.activity_logs
  for select to authenticated
  using (public.is_active_admin());

-- ---------------------------------------------------------------------------
-- app_settings
-- ---------------------------------------------------------------------------
create policy settings_select_active_users on public.app_settings
  for select to authenticated
  using (public.is_active_user());

create policy settings_update_admin on public.app_settings
  for update to authenticated
  using (public.is_active_admin())
  with check (public.is_active_admin());

-- ---------------------------------------------------------------------------
-- Realtime (postgres_changes respects RLS)
-- ---------------------------------------------------------------------------
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table
      public.customers, public.customer_addresses, public.customer_deletions,
      public.profiles, public.app_settings;
  end if;
end;
$$;

-- Full row images let realtime deliver deleted rows' keys to subscribers.
alter table public.customers replica identity full;
alter table public.profiles replica identity full;
