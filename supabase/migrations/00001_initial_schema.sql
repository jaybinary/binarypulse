-- =====================================================================
-- BinaryPulse v2 — Postgres 15 Schema for Supabase
-- Run this in Supabase SQL Editor after creating the project.
-- =====================================================================

-- Postgres extensions used by Supabase
create extension if not exists "pgcrypto";
create extension if not exists "pg_cron" with schema extensions;
create extension if not exists "uuid-ossp";

-- =====================================================================
-- ENUMS
-- =====================================================================
create type user_role     as enum ('admin','leadership','hr','manager','member');
create type project_status as enum ('active','on_hold','closed','pre_sales');
create type log_status    as enum (
  'having_task','no_task','research','internal_work',
  'waiting_client','waiting_pm','qa_review','deployment',
  'leave','training'
);
create type category_type  as enum (
  'development','design','qa','research','meeting',
  'client_support','internal_rd','catalog','admin','marketing'
);
create type priority_type  as enum ('P1','P2','P3');
create type proficiency    as enum ('L1','L2','L3');
create type skill_category as enum (
  'frontend','backend','mobile','design','marketing',
  'data','qa','ops','soft','tool'
);
create type blocker_sev    as enum ('low','medium','high','critical');

-- =====================================================================
-- TABLES
-- =====================================================================

create table departments (
  id            bigint generated always as identity primary key,
  name          text not null unique,
  lead_user_id  uuid,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table users (
  id              uuid primary key,                       -- links to auth.users.id
  email           text not null unique,
  name            text not null,
  department_id   bigint not null references departments(id),
  designation     text,
  reporting_to_id uuid references users(id) on delete set null,
  role            user_role not null default 'member',
  standard_hours  numeric(4,1) not null default 8.0,
  default_billable boolean not null default true,
  active          boolean not null default true,
  avatar_url      text,
  last_login_at   timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index idx_users_dept_active on users(department_id, active);
create index idx_users_mgr on users(reporting_to_id);
create index idx_users_role on users(role);

alter table departments
  add constraint fk_dept_lead foreign key (lead_user_id) references users(id) on delete set null;

create table allow_list (
  id          bigint generated always as identity primary key,
  email       text not null unique,
  invited_by  uuid references users(id) on delete set null,
  invited_at  timestamptz not null default now(),
  expires_at  timestamptz,
  consumed_at timestamptz
);

create table clients (
  id          bigint generated always as identity primary key,
  name        text not null unique,
  industry    text,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table projects (
  id              bigint generated always as identity primary key,
  code            text not null unique,
  name            text not null,
  client_id       bigint references clients(id) on delete set null,
  owner_user_id   uuid   references users(id)   on delete set null,
  status          project_status not null default 'active',
  start_date      date,
  end_date        date,
  billable        boolean not null default true,
  zoho_project_id text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index idx_proj_status on projects(status);
create index idx_proj_owner  on projects(owner_user_id);

create table skills (
  id          bigint generated always as identity primary key,
  name        text not null unique,
  category    skill_category not null,
  description text,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index idx_skill_cat on skills(category, active);

create table user_skills (
  id              bigint generated always as identity primary key,
  user_id         uuid   not null references users(id)  on delete cascade,
  skill_id        bigint not null references skills(id) on delete cascade,
  proficiency     proficiency not null,
  last_used_date  date,
  tagged_by       uuid   references users(id) on delete set null,
  tagged_at       timestamptz not null default now(),
  unique (user_id, skill_id)
);
create index idx_us_skill_prof on user_skills(skill_id, proficiency);

create table project_skills (
  id              bigint generated always as identity primary key,
  project_id      bigint not null references projects(id) on delete cascade,
  skill_id        bigint not null references skills(id)   on delete cascade,
  min_proficiency proficiency not null default 'L2',
  unique (project_id, skill_id)
);

create table daily_logs (
  id              bigint generated always as identity primary key,
  user_id         uuid not null references users(id) on delete cascade,
  log_date        date not null,
  status          log_status not null,
  project_id      bigint references projects(id) on delete set null,
  task_description text,
  actual_hours    numeric(4,1),
  standard_hours  numeric(4,1),
  variance_hours  numeric(4,1) generated always as (actual_hours - standard_hours) stored,
  category        category_type,
  priority        priority_type,
  billable        boolean,
  blocker         text,
  next_action     text,
  assigned_by     uuid references users(id) on delete set null,
  remarks         text,
  late_entry      boolean not null default false,
  source          text not null default 'web',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (user_id, log_date)
);
create index idx_dl_date_status on daily_logs(log_date, status);
create index idx_dl_proj_date   on daily_logs(project_id, log_date);
create index idx_dl_user_date   on daily_logs(user_id, log_date);

create table blockers (
  id           bigint generated always as identity primary key,
  daily_log_id bigint not null references daily_logs(id) on delete cascade,
  opened_on    date not null,
  resolved_on  date,
  severity     blocker_sev not null default 'medium',
  description  text not null,
  notes        text
);
create index idx_bl_open on blockers(resolved_on, opened_on);

create table audit_log (
  id            bigint generated always as identity primary key,
  actor_user_id uuid references users(id) on delete set null,
  action        text not null,
  entity        text not null,
  entity_id     text,
  meta          jsonb,
  ip            text,
  user_agent    text,
  created_at    timestamptz not null default now()
);
create index idx_audit_entity on audit_log(entity, entity_id);
create index idx_audit_actor  on audit_log(actor_user_id, created_at);

create table settings (
  k          text primary key,
  v          jsonb not null,
  updated_at timestamptz not null default now()
);

-- =====================================================================
-- updated_at TRIGGER
-- =====================================================================
create or replace function set_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

do $$ declare t text;
begin
  for t in select table_name from information_schema.columns
           where table_schema='public' and column_name='updated_at'
  loop
    execute format('create trigger trg_%I_upd before update on %I for each row execute function set_updated_at();', t, t);
  end loop;
end $$;

-- =====================================================================
-- ROW LEVEL SECURITY
-- =====================================================================
alter table users          enable row level security;
alter table departments    enable row level security;
alter table allow_list     enable row level security;
alter table clients        enable row level security;
alter table projects       enable row level security;
alter table skills         enable row level security;
alter table user_skills    enable row level security;
alter table project_skills enable row level security;
alter table daily_logs     enable row level security;
alter table blockers       enable row level security;
alter table audit_log      enable row level security;
alter table settings       enable row level security;

-- Helper: current user's row
create or replace function me() returns users as $$
  select * from users where id = auth.uid()
$$ language sql security definer stable;

create or replace function my_role() returns user_role as $$
  select role from users where id = auth.uid()
$$ language sql security definer stable;

create or replace function my_dept() returns bigint as $$
  select department_id from users where id = auth.uid()
$$ language sql security definer stable;

-- USERS
create policy "users_self_read" on users for select using (id = auth.uid());
create policy "users_team_read" on users for select using (reporting_to_id = auth.uid());
create policy "users_org_read"  on users for select using (my_role() in ('admin','leadership','hr'));
create policy "users_admin_write" on users for all
  using (my_role() = 'admin') with check (my_role() = 'admin');
create policy "users_hr_skills_write" on users for update
  using (my_role() in ('admin','hr')) with check (my_role() in ('admin','hr'));

-- DEPARTMENTS, CLIENTS, PROJECTS, SKILLS — read for any authenticated user
create policy "read_all_authed_dept"     on departments    for select using (auth.uid() is not null);
create policy "read_all_authed_clients"  on clients        for select using (auth.uid() is not null);
create policy "read_all_authed_projects" on projects       for select using (auth.uid() is not null);
create policy "read_all_authed_skills"   on skills         for select using (auth.uid() is not null);
create policy "read_all_authed_pskills"  on project_skills for select using (auth.uid() is not null);

-- Admin/HR can write masters
create policy "admin_writes_dept"     on departments    for all
  using (my_role() in ('admin','hr')) with check (my_role() in ('admin','hr'));
create policy "admin_writes_clients"  on clients        for all
  using (my_role() in ('admin','hr')) with check (my_role() in ('admin','hr'));
create policy "admin_writes_projects" on projects       for all
  using (my_role() in ('admin','hr','manager')) with check (my_role() in ('admin','hr','manager'));
create policy "admin_writes_skills"   on skills         for all
  using (my_role() in ('admin','hr')) with check (my_role() in ('admin','hr'));
create policy "admin_writes_pskills"  on project_skills for all
  using (my_role() in ('admin','hr','manager')) with check (my_role() in ('admin','hr','manager'));

-- USER_SKILLS
create policy "us_self_read"     on user_skills for select using (user_id = auth.uid() or my_role() in ('admin','leadership','hr','manager'));
create policy "us_mgr_write"     on user_skills for all
  using (my_role() in ('admin','hr') or (my_role() = 'manager' and
          exists (select 1 from users u where u.id = user_skills.user_id and u.reporting_to_id = auth.uid())))
  with check (my_role() in ('admin','hr') or (my_role() = 'manager' and
          exists (select 1 from users u where u.id = user_skills.user_id and u.reporting_to_id = auth.uid())));

-- DAILY_LOGS
create policy "dl_self_all"    on daily_logs for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "dl_mgr_read"    on daily_logs for select using (
  my_role() in ('admin','leadership','hr')
  or (my_role() = 'manager' and exists (
        select 1 from users u where u.id = daily_logs.user_id and u.reporting_to_id = auth.uid()))
);
create policy "dl_mgr_update_assignment" on daily_logs for update using (
  my_role() in ('admin','manager')
);

-- BLOCKERS
create policy "bl_authed_read"   on blockers for select using (auth.uid() is not null);
create policy "bl_owner_write"   on blockers for all using (
  exists (select 1 from daily_logs d where d.id = blockers.daily_log_id and d.user_id = auth.uid())
  or my_role() in ('admin','manager')
);

-- AUDIT — only admin/leadership can read
create policy "audit_admin_read" on audit_log for select using (my_role() in ('admin','leadership'));

-- SETTINGS — admin only writes; everyone reads
create policy "settings_read"  on settings for select using (auth.uid() is not null);
create policy "settings_write" on settings for all using (my_role() = 'admin') with check (my_role() = 'admin');

-- ALLOW_LIST — admin only
create policy "allow_admin_all" on allow_list for all using (my_role() = 'admin') with check (my_role() = 'admin');

-- =====================================================================
-- AUDIT TRIGGER (generic)
-- =====================================================================
create or replace function audit_change() returns trigger as $$
declare
  v_action text;
begin
  if tg_op = 'INSERT' then v_action := 'create';
  elsif tg_op = 'UPDATE' then v_action := 'update';
  elsif tg_op = 'DELETE' then v_action := 'delete';
  end if;
  insert into audit_log(actor_user_id, action, entity, entity_id, meta)
  values (auth.uid(), v_action, tg_table_name,
          coalesce((new).id::text, (old).id::text),
          jsonb_build_object('old', row_to_json(old), 'new', row_to_json(new)));
  return coalesce(new, old);
end;
$$ language plpgsql security definer;

create trigger trg_audit_users        after insert or update or delete on users        for each row execute function audit_change();
create trigger trg_audit_projects     after insert or update or delete on projects     for each row execute function audit_change();
create trigger trg_audit_skills       after insert or update or delete on skills       for each row execute function audit_change();
create trigger trg_audit_daily_logs   after insert or update or delete on daily_logs   for each row execute function audit_change();

-- =====================================================================
-- pg_cron — daily digest at 12:30 IST (07:00 UTC)
-- =====================================================================
-- Note: the actual digest logic will live in a Supabase Edge Function.
-- pg_cron just invokes it on schedule.
-- select cron.schedule('binarypulse_daily_digest', '0 7 * * 1-6',
--   $$select net.http_post(url := 'https://<project>.functions.supabase.co/daily-digest',
--                          headers := '{"Authorization": "Bearer <service_role>"}'::jsonb);$$);

-- =====================================================================
-- SEED DATA
-- =====================================================================
insert into departments (name) values
('Marketing Lead'),('PM Team'),('UI/UX'),('Frontend'),('Backend'),
('Mobile'),('QA'),('Catalog'),('Digital Marketing'),('HR/Admin'),('Accounts');

insert into settings (k,v) values
('working_days',        '["Mon","Tue","Wed","Thu","Fri","Sat"]'::jsonb),
('default_std_hours',   '{"full_day":8,"half_day":4}'::jsonb),
('digest_time_ist',     '"12:30"'::jsonb),
('reminder_time_ist',   '"11:30"'::jsonb),
('blocker_alert_hours', '{"warn":24,"escalate":48}'::jsonb);

insert into skills (name, category) values
('Shopify Liquid','frontend'),('Shopify App Dev','frontend'),('React','frontend'),
('Vue','frontend'),('HTML/CSS','frontend'),('JavaScript','frontend'),
('Tailwind CSS','frontend'),('Vite/Webpack','frontend'),
('Laravel','backend'),('PHP Core','backend'),('Node.js','backend'),
('MySQL','backend'),('PostgreSQL','backend'),('REST API Design','backend'),
('AWS','ops'),('Docker','ops'),('CI/CD','ops'),('Nginx','ops'),
('React Native','mobile'),('Flutter','mobile'),('Android (Kotlin)','mobile'),('iOS (Swift)','mobile'),
('Figma','design'),('Adobe XD','design'),('UI Design','design'),('UX Research','design'),
('Manual QA','qa'),('Automation (Cypress)','qa'),('API Testing (Postman)','qa'),
('Google Ads','marketing'),('Meta Ads','marketing'),('SEO','marketing'),
('Email Marketing (Klaviyo)','marketing'),('Content Writing','marketing'),
('Product Catalog Management','tool'),('Image Editing','tool'),('Video Editing','tool'),
('Stakeholder Management','soft'),('Client Communication','soft'),('Mentoring','soft'),
('Google Analytics','data'),('Looker / Data Studio','data'),('SQL','data'),('Excel/Sheets Advanced','data');

-- =====================================================================
-- END
-- =====================================================================
