-- OUTIFOR — atomic customer save
-- Creates or updates a customer, its extra addresses and its admin notes in a
-- single transaction. SECURITY INVOKER: every statement runs under the
-- caller's RLS policies, so employees are rejected exactly as with direct writes.
--
-- p_expected_updated_at enables optimistic concurrency: if another admin saved
-- the customer since this form was opened, the save is refused instead of
-- silently overwriting their change.

create or replace function public.customer_json(p_id uuid)
returns jsonb
language sql
stable
set search_path = ''
as $$
  select to_jsonb(c) - 'search_text' - 'name_key'
         || jsonb_build_object('customer_addresses', coalesce((
              select jsonb_agg(to_jsonb(a) order by a.created_at)
              from public.customer_addresses a where a.customer_id = c.id), '[]'::jsonb))
  from public.customers c
  where c.id = p_id;
$$;

create or replace function public.save_customer(
  p_id uuid,
  p_data jsonb,
  p_addresses jsonb default null,
  p_notes text default null,
  p_expected_updated_at timestamptz default null
)
returns jsonb
language plpgsql
set search_path = ''
as $$
declare
  v_id uuid := p_id;
  v_current timestamptz;
  v_keep uuid[];
  v_addr jsonb;
begin
  if not public.is_active_admin() then
    raise exception 'Administrator privileges required' using errcode = '42501';
  end if;

  if v_id is null then
    insert into public.customers (
      first_name, last_name, business_name, primary_phone, secondary_phone, whatsapp_phone,
      wilaya, commune, address, latitude, longitude, status)
    values (
      p_data ->> 'first_name', p_data ->> 'last_name', p_data ->> 'business_name',
      p_data ->> 'primary_phone', p_data ->> 'secondary_phone', p_data ->> 'whatsapp_phone',
      p_data ->> 'wilaya', p_data ->> 'commune', p_data ->> 'address',
      (p_data ->> 'latitude')::double precision, (p_data ->> 'longitude')::double precision,
      coalesce(p_data ->> 'status', 'active'))
    returning id into v_id;
  else
    select updated_at into v_current from public.customers where id = v_id for update;
    if not found then
      raise exception 'Customer not found' using errcode = 'P0002';
    end if;
    if p_expected_updated_at is not null and v_current <> p_expected_updated_at then
      raise exception 'This customer was modified by someone else. Reload and try again.'
        using errcode = '40001';
    end if;
    update public.customers set
      first_name      = p_data ->> 'first_name',
      last_name       = p_data ->> 'last_name',
      business_name   = p_data ->> 'business_name',
      primary_phone   = p_data ->> 'primary_phone',
      secondary_phone = p_data ->> 'secondary_phone',
      whatsapp_phone  = p_data ->> 'whatsapp_phone',
      wilaya          = p_data ->> 'wilaya',
      commune         = p_data ->> 'commune',
      address         = p_data ->> 'address',
      latitude        = (p_data ->> 'latitude')::double precision,
      longitude       = (p_data ->> 'longitude')::double precision,
      status          = coalesce(p_data ->> 'status', status)
    where id = v_id;
  end if;

  if p_addresses is not null then
    if jsonb_typeof(p_addresses) <> 'array' or jsonb_array_length(p_addresses) > 20 then
      raise exception 'Invalid address list' using errcode = '22023';
    end if;

    select coalesce(array_agg((a ->> 'id')::uuid) filter (where a ->> 'id' is not null), '{}')
      into v_keep from jsonb_array_elements(p_addresses) a;
    delete from public.customer_addresses where customer_id = v_id and not (id = any (v_keep));

    for v_addr in select * from jsonb_array_elements(p_addresses) loop
      if v_addr ->> 'id' is null then
        insert into public.customer_addresses (customer_id, label, address, wilaya, commune, latitude, longitude)
        values (v_id, v_addr ->> 'label', v_addr ->> 'address', v_addr ->> 'wilaya', v_addr ->> 'commune',
                (v_addr ->> 'latitude')::double precision, (v_addr ->> 'longitude')::double precision);
      else
        update public.customer_addresses set
          label = v_addr ->> 'label', address = v_addr ->> 'address',
          wilaya = v_addr ->> 'wilaya', commune = v_addr ->> 'commune',
          latitude = (v_addr ->> 'latitude')::double precision,
          longitude = (v_addr ->> 'longitude')::double precision
        where id = (v_addr ->> 'id')::uuid and customer_id = v_id;
      end if;
    end loop;
  end if;

  if p_notes is not null then
    if btrim(p_notes) = '' then
      delete from public.customer_admin_notes where customer_id = v_id;
    else
      insert into public.customer_admin_notes (customer_id, notes) values (v_id, btrim(p_notes))
      on conflict (customer_id) do update set notes = excluded.notes;
    end if;
  end if;

  return public.customer_json(v_id);
end;
$$;

revoke all on function public.customer_json(uuid) from public, anon;
revoke all on function public.save_customer(uuid, jsonb, jsonb, text, timestamptz) from public, anon;
grant execute on function public.customer_json(uuid) to authenticated, service_role;
grant execute on function public.save_customer(uuid, jsonb, jsonb, text, timestamptz) to authenticated, service_role;
