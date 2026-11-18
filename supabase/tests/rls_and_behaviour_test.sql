-- OUTIFOR database tests: permissions (RLS / grants) and server-side behaviour.
-- Runs as plain SQL through psql: scripts/test_db.sh
-- Each check raises an exception on failure; ON_ERROR_STOP aborts the run.

\set ON_ERROR_STOP 1
\set QUIET 1
set client_min_messages = notice;

\set admin_id  '''a0000000-0000-4000-8000-000000000001'''
\set admin2_id '''a0000000-0000-4000-8000-000000000002'''
\set emp_id    '''e0000000-0000-4000-8000-000000000001'''
\set emp2_id   '''e0000000-0000-4000-8000-000000000002'''
\set rogue_id  '''f0000000-0000-4000-8000-000000000001'''

create schema if not exists tests;
create or replace function tests.check(cond boolean, label text) returns void language plpgsql as $$
begin
  if cond is distinct from true then
    raise exception 'FAILED: %', label;
  end if;
  raise notice 'ok - %', label;
end;
$$;

-- Runs a statement that must fail (permission or validation error).
create or replace function tests.must_fail(stmt text, label text) returns void language plpgsql as $$
begin
  begin
    execute stmt;
  exception when others then
    raise notice 'ok - % (rejected: %)', label, sqlerrm;
    return;
  end;
  raise exception 'FAILED: % (statement succeeded: %)', label, stmt;
end;
$$;

grant execute on function tests.check(boolean, text) to public;
grant execute on function tests.must_fail(text, text) to public;
grant usage on schema tests to public;

-- ---------------------------------------------------------------------------
\echo '== Account provisioning'
-- ---------------------------------------------------------------------------
insert into auth.users (id, email, raw_app_meta_data, raw_user_meta_data) values
  (:admin_id,  'directeur@users.outifor.app', '{"role":"admin","username":"directeur","outifor_provisioned":true}', '{"full_name":"Karim Directeur"}'),
  (:admin2_id, 'adjoint@users.outifor.app',   '{"role":"admin","username":"adjoint","outifor_provisioned":true}',   '{"full_name":"Adjoint Admin"}'),
  (:emp_id,    'livreur1@users.outifor.app',  '{"username":"livreur1","outifor_provisioned":true}',                 '{"full_name":"Samir Livreur"}'),
  (:emp2_id,   'livreur2@users.outifor.app',  '{"username":"livreur2","outifor_provisioned":true}',                 '{"full_name":"Yacine Livreur"}'),
  -- Self sign-up (if it were left enabled): user metadata claims admin, app metadata is empty.
  (:rogue_id,  'rogue@example.com', '{}', '{"full_name":"Rogue","role":"admin"}');

select tests.check((select role = 'admin' and is_active from public.profiles where id = :admin_id), 'provisioned admin is an active admin');
select tests.check((select role = 'employee' and is_active from public.profiles where id = :emp_id), 'provisioned employee is active');
select tests.check((select role = 'employee' and not is_active from public.profiles where id = :rogue_id),
  'self-registered account is an inactive employee (user metadata cannot grant admin)');

update auth.users set last_sign_in_at = now() where id = :emp_id;
select tests.check((select last_login_at is not null from public.profiles where id = :emp_id), 'sign-in updates last_login_at');

-- ---------------------------------------------------------------------------
\echo '== Anonymous access'
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"role":"anon"}', false);
set role anon;
select tests.must_fail('select * from public.customers', 'anon cannot read customers');
select tests.must_fail('select * from public.profiles', 'anon cannot read profiles');
select tests.must_fail('select public.search_customers(''a'')', 'anon cannot call search');
reset role;

-- ---------------------------------------------------------------------------
\echo '== Admin creates customers'
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}', false);
set role authenticated;

insert into public.customers (reference, first_name, last_name, business_name, primary_phone, whatsapp_phone, wilaya, commune, address, latitude, longitude)
values ('HACKED-1', '  Mohamed ', 'Benali', 'Quincaillerie Benali', '+213 555 12 34 56', '00213555123456', 'Alger', 'Bab Ezzouar', 'Cité 1200 logements, bt 5', 36.7213, 3.1834);

insert into public.customers (first_name, last_name, primary_phone, wilaya, commune, address)
values ('مُحَمَّد', 'بن علي', '0661 00 11 22', 'Blida', 'Boufarik', 'Rue des frères Abed'),
       ('Amina', 'Kaci', '0770112233', 'Oran', 'Bir El Djir', 'Hai Khemisti, local 4');

select tests.check((select reference from public.customers where last_name = 'Benali') ~ '^OUT-[0-9]{6}$',
  'reference generated server-side (client value ignored)');
select tests.check((select count(distinct reference) = 3 from public.customers), 'references are unique');
select tests.check((select first_name = 'Mohamed' and primary_phone = '0555123456' and whatsapp_phone = '0555123456'
                      from public.customers where last_name = 'Benali'), 'names trimmed, +213/00213 phones normalised');
select tests.check((select created_by = :admin_id from public.customers where last_name = 'Benali'), 'created_by is the caller');
select tests.check((select latitude is null from public.customers where last_name = 'Kaci'), 'missing coordinates stay null');

select tests.must_fail($$insert into public.customers (first_name, last_name, primary_phone, wilaya, commune, address, latitude)
  values ('X', 'Y', '0555000000', 'Alger', 'Alger', 'Somewhere', 36.7)$$, 'latitude without longitude rejected');
select tests.must_fail($$insert into public.customers (first_name, last_name, primary_phone, wilaya, commune, address)
  values ('X', 'Y', 'abc', 'Alger', 'Alger', 'Somewhere')$$, 'invalid phone rejected');
select tests.must_fail($$insert into public.customers (first_name, last_name, primary_phone, wilaya, commune, address, latitude, longitude)
  values ('X', 'Y', '0555000000', 'Alger', 'Alger', 'Somewhere', 120, 3)$$, 'out-of-range latitude rejected');

insert into public.customer_admin_notes (customer_id, notes)
select id, 'Pays late, call before 10h' from public.customers where last_name = 'Benali';

select tests.check((select count(*) = 1 from public.activity_logs where action = 'customer_created' and details->>'name' = 'Mohamed Benali'),
  'creation is audited');

\echo '== Search'
select tests.check((select count(*) >= 1 from public.search_customers('mohammed') where last_name = 'Benali'),
  'search: Mohammed matches Mohamed (doubled letters)');
select tests.check((select count(*) >= 1 from public.search_customers('  benal ') where last_name = 'Benali'),
  'search: partial last name with surrounding spaces');
select tests.check((select count(*) = 1 from public.search_customers('محمد')), 'search: Arabic name without diacritics matches name with tashkeel');
select tests.check((select count(*) = 1 from public.search_customers('ﺑﻦ')) or (select count(*) = 1 from public.search_customers('بن')),
  'search: Arabic partial last name');
select tests.check((select count(*) = 1 from public.search_customers('OUT-000002')), 'search: by reference');
select tests.check((select count(*) = 1 from public.search_customers('000003')), 'search: by partial reference');
select tests.check((select count(*) = 1 from public.search_customers('0770 11')), 'search: by partial phone with spaces');
select tests.check((select count(*) = 1 from public.search_customers('+213 555 123')), 'search: by international phone prefix');
select tests.check((select count(*) = 1 from public.search_customers('kaci amina')), 'search: full name in reverse order');
select tests.check((select count(*) = 0 from public.search_customers('qwerty')), 'search: no false positives');

\echo '== Duplicate detection'
select tests.check((select reason = 'phone' from public.find_customer_duplicates('Other', 'Person', array['+213555123456']) limit 1),
  'duplicate check: same phone found');
select tests.check((select count(*) >= 1 from public.find_customer_duplicates('Mohammed', 'Benaly', '{}') where last_name = 'Benali'),
  'duplicate check: similar name found');
select tests.check((select count(*) >= 1 from public.find_customer_duplicates('Benali', 'Mohamed', '{}') where last_name = 'Benali'),
  'duplicate check: swapped first/last name found');
select tests.check((select count(*) = 0 from public.find_customer_duplicates('Mohamed', 'Benali', '{}',
  (select id from public.customers where last_name = 'Benali'))), 'duplicate check: record being edited is excluded');

insert into public.customers (first_name, last_name, primary_phone, wilaya, commune, address)
values ('Mohamed', 'Benali', '0699887766', 'Alger', 'Kouba', 'Rue Garidi');
select tests.check((select count(*) = 1 from public.list_potential_duplicates()), 'review list: duplicate pair listed (records not merged)');
select public.dismiss_duplicate_pair(customer_a, customer_b) from public.list_potential_duplicates();
select tests.check((select count(*) = 0 from public.list_potential_duplicates()), 'review list: dismissed pair hidden');
select tests.check((select count(*) = 4 from public.customers), 'no automatic merge');

\echo '== Admin edits, archives, addresses'
select tests.must_fail($$update public.customers set reference = 'OUT-999999' where last_name = 'Kaci'$$,
  'reference column is not updatable');
update public.customers set latitude = 35.70, longitude = -0.58 where last_name = 'Kaci';
select tests.check((select action = 'customer_location_updated' from public.activity_logs order by id desc limit 1),
  'location change audited as customer_location_updated');
update public.customers set status = 'archived' where last_name = 'Kaci';
select tests.check((select action = 'customer_archived' from public.activity_logs order by id desc limit 1), 'archive audited');
select tests.check((select count(*) = 0 from public.search_customers('kaci')), 'search excludes archived by default');
select tests.check((select count(*) = 1 from public.search_customers('kaci', true)), 'search includes archived when asked');

create temp table t_before as select updated_at from public.customers where last_name = 'Benali' and commune = 'Bab Ezzouar';
grant select on t_before to public;
select pg_sleep(0.01);
insert into public.customer_addresses (customer_id, label, address, wilaya, commune, latitude, longitude)
select id, 'Dépôt', 'Zone industrielle, lot 12', 'Alger', 'Rouiba', 36.73, 3.28 from public.customers where commune = 'Bab Ezzouar';
select tests.check((select c.updated_at > b.updated_at from public.customers c, t_before b where c.commune = 'Bab Ezzouar'),
  'adding an address bumps customer.updated_at (delta sync)');

select tests.check((select (public.admin_dashboard_stats() ->> 'customers_archived')::int = 1), 'dashboard stats readable by admin');
update public.app_settings set company_name = 'OutiFor Quincaillerie';
select tests.check((select company_name = 'OutiFor Quincaillerie' from public.app_settings), 'admin updates settings');
reset role;

-- ---------------------------------------------------------------------------
\echo '== Employee permissions (direct API access)'
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"e0000000-0000-4000-8000-000000000001","role":"authenticated"}', false);
set role authenticated;

select tests.check((select count(*) = 4 from public.customers), 'employee reads the directory');
select tests.check((select count(*) = 1 from public.customer_addresses), 'employee reads extra addresses');
select tests.check((select count(*) = 0 from public.customer_admin_notes), 'employee cannot read admin notes');
select tests.check((select count(*) >= 1 from public.search_customers('benali')), 'employee can search');

select tests.must_fail($$insert into public.customers (first_name, last_name, primary_phone, wilaya, commune, address)
  values ('Fake', 'Customer', '0555000001', 'Alger', 'Alger', 'Nowhere')$$, 'employee cannot insert customers');
update public.customers set primary_phone = '0555000002' where last_name = 'Benali';
select tests.check((select count(*) = 0 from public.customers where primary_phone = '0555000002'), 'employee update has no effect');
delete from public.customers;
select tests.check((select count(*) = 4 from public.customers), 'employee delete has no effect');
select tests.must_fail($$insert into public.customer_admin_notes (customer_id, notes)
  select id, 'x' from public.customers limit 1$$, 'employee cannot write admin notes');
select tests.must_fail($$insert into public.customer_addresses (customer_id, label, address)
  select id, 'x', 'xxxx' from public.customers limit 1$$, 'employee cannot add addresses');

select tests.check((select count(*) = 1 from public.profiles), 'employee sees only own profile');
update public.profiles set role = 'admin' where id = :emp_id;
select tests.check((select role = 'employee' from public.profiles where id = :emp_id), 'employee cannot promote self via update');
select tests.must_fail($$update public.profiles set last_login_at = now() where id = 'e0000000-0000-4000-8000-000000000001'$$,
  'employee cannot write last_login_at');
select public.update_own_profile('Samir B.', '0555 44 33 22');
select tests.check((select full_name = 'Samir B.' and phone = '0555443322' and role = 'employee' from public.profiles where id = :emp_id),
  'employee updates own name/phone through RPC only');

select tests.check((select count(*) = 0 from public.activity_logs), 'employee cannot read activity logs');
select tests.must_fail($$insert into public.activity_logs (actor_id, action) values ('a0000000-0000-4000-8000-000000000001', 'customer_deleted')$$,
  'employee cannot forge activity logs');
select public.log_customer_action('customer_called', (select id from public.customers where commune = 'Bab Ezzouar'));
select public.log_customer_action('customer_called', (select id from public.customers where commune = 'Bab Ezzouar'));
select tests.must_fail($$select public.log_customer_action('customer_deleted', (select id from public.customers limit 1))$$,
  'employee cannot log admin actions');
select tests.must_fail('select public.admin_dashboard_stats()', 'employee cannot read admin stats');
select tests.must_fail($$select * from public.find_customer_duplicates('a', 'b')$$, 'employee cannot run duplicate check');
select tests.must_fail('select * from public.list_potential_duplicates()', 'employee cannot list duplicates');
select tests.must_fail('select public.assert_active_admin()', 'internal helper not callable');
update public.app_settings set company_name = 'Hacked';
select tests.check((select company_name = 'OutiFor Quincaillerie' from public.app_settings), 'employee cannot change settings');
select tests.check((select count(*) = 1 from public.current_profile()), 'current_profile returns active employee');
reset role;

select tests.check((select count(*) = 1 from public.activity_logs where action = 'customer_called' and actor_id = :emp_id),
  'call logged once with the employee as actor (double tap ignored)');

-- ---------------------------------------------------------------------------
\echo '== Self-registered account'
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"f0000000-0000-4000-8000-000000000001","role":"authenticated"}', false);
set role authenticated;
select tests.check((select count(*) = 0 from public.customers), 'unprovisioned account reads no customers');
select tests.check((select count(*) = 0 from public.current_profile()), 'unprovisioned account has no active profile');
reset role;

-- ---------------------------------------------------------------------------
\echo '== Deactivation and admin guards'
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}', false);
set role authenticated;
update public.profiles set is_active = false where id = :emp2_id;
select tests.must_fail($$update public.profiles set is_active = false where id = 'a0000000-0000-4000-8000-000000000001'$$,
  'admin cannot deactivate self');
select tests.must_fail($$update public.profiles set role = 'employee' where id = 'a0000000-0000-4000-8000-000000000001'$$,
  'admin cannot demote self');
reset role;

select set_config('request.jwt.claims', '{"sub":"e0000000-0000-4000-8000-000000000002","role":"authenticated"}', false);
set role authenticated;
select tests.check((select count(*) = 0 from public.customers), 'deactivated employee immediately loses customer access');
select tests.check((select count(*) = 0 from public.customer_deletions), 'deactivated employee cannot read sync tombstones');
select tests.must_fail($$select public.log_customer_action('customer_viewed', (select id from public.customers limit 1))$$,
  'deactivated employee cannot log actions');
reset role;

-- Service role (Edge Function) path: the last active admin is protected.
set role service_role;
update public.profiles set is_active = false where id = :admin2_id;
select tests.must_fail($$update public.profiles set role = 'employee' where id = 'a0000000-0000-4000-8000-000000000001'$$,
  'last active admin cannot be demoted, even by the service role');
reset role;

-- ---------------------------------------------------------------------------
\echo '== Deletion and sync tombstones'
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}', false);
set role authenticated;
delete from public.customers where last_name = 'Kaci';
select tests.check((select count(*) = 1 from public.customer_deletions), 'delete writes a tombstone');
select tests.check((select action = 'customer_deleted' and details->>'name' = 'Amina Kaci' from public.activity_logs order by id desc limit 1),
  'delete audited with name and reference');
reset role;

select set_config('request.jwt.claims', '{"sub":"e0000000-0000-4000-8000-000000000001","role":"authenticated"}', false);
set role authenticated;
select tests.check((select count(*) = 1 from public.customer_deletions), 'active employee receives tombstones for sync');
select tests.check((select count(*) = 3 from public.customers), 'deleted customer gone for employees');
reset role;

\echo 'All database tests passed.'
