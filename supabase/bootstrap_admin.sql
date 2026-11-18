-- OUTIFOR — promote the first administrator.
--
-- 1. Supabase Dashboard → Authentication → Users → "Add user" → "Create new user"
--    Email:    directeur@outifor.local   (username "directeur" + LOGIN_DOMAIN)
--    Password: a strong password;  tick "Auto Confirm User".
-- 2. Edit the three values below, then run this file in the SQL Editor.
--    (The SQL Editor runs as the database owner, which the profile guard allows.)
--
-- Every later account (employees and other admins) is created from the app.

do $$
declare
  v_email    text := 'directeur@outifor.local';
  v_username text := 'directeur';
  v_name     text := 'Directeur';
  v_id       uuid;
begin
  select id into v_id from auth.users where lower(email) = lower(v_email);
  if v_id is null then
    raise exception 'No auth user with email %. Create it in Authentication → Users first.', v_email;
  end if;

  update auth.users
     set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb)
           || jsonb_build_object('role', 'admin', 'username', v_username, 'outifor_provisioned', true)
   where id = v_id;

  update public.profiles
     set role = 'admin', is_active = true, username = v_username, full_name = v_name
   where id = v_id;

  raise notice 'User % (%) is now an active administrator.', v_username, v_email;
end;
$$;
