// OUTIFOR — admin-users Edge Function
//
// The only place that uses the service-role key. It creates staff accounts,
// resets passwords and activates or deactivates accounts. Every request must
// carry the JWT of an ACTIVE ADMIN; the role is read from public.profiles,
// never from the request body or user metadata.
//
// Deploy: supabase functions deploy admin-users
// Secrets: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are injected by Supabase.
//          OUTIFOR_LOGIN_DOMAIN (optional) must match the app's LOGIN_DOMAIN.

import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2.45.4";

const LOGIN_DOMAIN = Deno.env.get("OUTIFOR_LOGIN_DOMAIN") ?? "outifor.local";
const USERNAME_RE = /^[a-z0-9][a-z0-9._-]{2,31}$/;
const BAN_FOREVER = "876000h"; // 100 years

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

class HttpError extends Error {
  constructor(public status: number, public code: string, message: string) {
    super(message);
  }
}

function json(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function requireString(body: Record<string, unknown>, key: string): string {
  const value = body[key];
  if (typeof value !== "string" || value.trim() === "") {
    throw new HttpError(400, "invalid_input", `Missing field: ${key}`);
  }
  return value.trim();
}

function validatePassword(password: string): void {
  if (password.length < 8 || password.length > 72) {
    throw new HttpError(400, "weak_password", "Password must be 8 to 72 characters long");
  }
  if (!/[A-Za-z]/.test(password) || !/[0-9]/.test(password)) {
    throw new HttpError(400, "weak_password", "Password must contain letters and digits");
  }
}

function validateFullName(name: string): void {
  if (name.length < 2 || name.length > 120) {
    throw new HttpError(400, "invalid_name", "Full name must be 2 to 120 characters long");
  }
}

async function requireAdmin(admin: SupabaseClient, req: Request): Promise<string> {
  const token = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (!token) throw new HttpError(401, "unauthenticated", "Missing session");

  const { data: userData, error: userError } = await admin.auth.getUser(token);
  if (userError || !userData.user) throw new HttpError(401, "unauthenticated", "Invalid or expired session");

  const { data: profile, error } = await admin
    .from("profiles")
    .select("id, role, is_active")
    .eq("id", userData.user.id)
    .maybeSingle();
  if (error) throw new HttpError(500, "server_error", error.message);
  if (!profile || !profile.is_active || profile.role !== "admin") {
    throw new HttpError(403, "forbidden", "Administrator privileges required");
  }
  return profile.id as string;
}

async function log(
  admin: SupabaseClient,
  actorId: string,
  action: string,
  targetId: string,
  details: Record<string, unknown> = {},
) {
  const { error } = await admin.from("activity_logs").insert({
    actor_id: actorId,
    action,
    target_profile_id: targetId,
    details,
  });
  if (error) console.error("activity log failed", error.message);
}

async function loadTarget(admin: SupabaseClient, userId: string) {
  const { data, error } = await admin
    .from("profiles")
    .select("id, username, full_name, role, is_active")
    .eq("id", userId)
    .maybeSingle();
  if (error) throw new HttpError(500, "server_error", error.message);
  if (!data) throw new HttpError(404, "not_found", "Account not found");
  return data;
}

async function createAccount(admin: SupabaseClient, actorId: string, body: Record<string, unknown>) {
  const fullName = requireString(body, "full_name");
  const username = requireString(body, "username").toLowerCase();
  const password = requireString(body, "password");
  const role = body.role === "admin" ? "admin" : "employee";
  validateFullName(fullName);
  validatePassword(password);
  if (!USERNAME_RE.test(username)) {
    throw new HttpError(400, "invalid_username",
      "Username: 3-32 characters, lowercase letters, digits, dot, dash or underscore");
  }

  const { data: existing } = await admin.from("profiles").select("id").ilike("username", username).maybeSingle();
  if (existing) throw new HttpError(409, "username_taken", "This username is already in use");

  const { data, error } = await admin.auth.admin.createUser({
    email: `${username}@${LOGIN_DOMAIN}`,
    password,
    email_confirm: true,
    app_metadata: { role, username, full_name: fullName, outifor_provisioned: true, created_by: actorId },
    user_metadata: { full_name: fullName },
  });
  if (error || !data.user) {
    const taken = /already|exists|registered/i.test(error?.message ?? "");
    throw new HttpError(taken ? 409 : 400, taken ? "username_taken" : "create_failed",
      error?.message ?? "Account creation failed");
  }

  await log(admin, actorId, "employee_created", data.user.id, { username, role });
  return await loadTarget(admin, data.user.id);
}

async function setActive(admin: SupabaseClient, actorId: string, body: Record<string, unknown>) {
  const userId = requireString(body, "user_id");
  if (typeof body.active !== "boolean") throw new HttpError(400, "invalid_input", "Missing field: active");
  const active = body.active;
  if (userId === actorId) throw new HttpError(400, "self_change", "You cannot change your own account status");
  await loadTarget(admin, userId);

  // Profile first: RLS blocks data access on the very next request.
  const { error } = await admin.from("profiles").update({ is_active: active }).eq("id", userId);
  if (error) throw new HttpError(400, "update_failed", error.message);

  // Then the auth ban: the session cannot be refreshed any more.
  const { error: banError } = await admin.auth.admin.updateUserById(userId, {
    ban_duration: active ? "none" : BAN_FOREVER,
  });
  if (banError) console.error("ban update failed", banError.message);

  await log(admin, actorId, active ? "employee_activated" : "employee_deactivated", userId);
  return await loadTarget(admin, userId);
}

async function resetPassword(admin: SupabaseClient, actorId: string, body: Record<string, unknown>) {
  const userId = requireString(body, "user_id");
  const password = requireString(body, "password");
  validatePassword(password);
  await loadTarget(admin, userId);
  const { error } = await admin.auth.admin.updateUserById(userId, { password });
  if (error) throw new HttpError(400, "update_failed", error.message);
  await log(admin, actorId, "employee_password_reset", userId);
  return await loadTarget(admin, userId);
}

async function updateAccount(admin: SupabaseClient, actorId: string, body: Record<string, unknown>) {
  const userId = requireString(body, "user_id");
  const fullName = requireString(body, "full_name");
  validateFullName(fullName);
  const target = await loadTarget(admin, userId);
  const changes: Record<string, unknown> = { full_name: fullName };
  if (body.role === "admin" || body.role === "employee") {
    if (body.role !== target.role && userId === actorId) {
      throw new HttpError(400, "self_change", "You cannot change your own role");
    }
    changes.role = body.role;
  }
  const { error } = await admin.from("profiles").update(changes).eq("id", userId);
  if (error) throw new HttpError(400, "update_failed", error.message);
  if (changes.role && changes.role !== target.role) {
    const { error: metaError } = await admin.auth.admin.updateUserById(userId, {
      app_metadata: { role: changes.role },
    });
    if (metaError) console.error("app_metadata update failed", metaError.message);
  }
  await log(admin, actorId, "employee_updated", userId, changes);
  return await loadTarget(admin, userId);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json(405, { error: "method_not_allowed", message: "Use POST" });

  const url = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !serviceKey) return json(500, { error: "misconfigured", message: "Server is not configured" });

  const admin = createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  try {
    const actorId = await requireAdmin(admin, req);
    let body: Record<string, unknown>;
    try {
      body = await req.json();
    } catch {
      throw new HttpError(400, "invalid_json", "Body must be JSON");
    }

    switch (body.action) {
      case "create":
        return json(200, { profile: await createAccount(admin, actorId, body) });
      case "set_active":
        return json(200, { profile: await setActive(admin, actorId, body) });
      case "reset_password":
        return json(200, { profile: await resetPassword(admin, actorId, body) });
      case "update":
        return json(200, { profile: await updateAccount(admin, actorId, body) });
      default:
        throw new HttpError(400, "unknown_action", "Unknown action");
    }
  } catch (err) {
    if (err instanceof HttpError) return json(err.status, { error: err.code, message: err.message });
    console.error(err);
    return json(500, { error: "server_error", message: "Unexpected error" });
  }
});
