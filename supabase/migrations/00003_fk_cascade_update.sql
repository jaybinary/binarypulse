-- =====================================================================
-- BinaryPulse — FK fix: add ON UPDATE CASCADE to all users(id) refs
-- Run this if 00002_seed_users.sql failed on the retroactive link step
-- (Error 23503: update or delete on users violates fk constraint).
-- =====================================================================
-- Why: when an existing auth user (e.g., Jayesh who signed up before
-- migration 00002 ran) is linked retroactively, his placeholder UUID
-- needs to be replaced with his real auth.uid. Other rows referencing
-- it (reporting_to_id, dept leads, etc.) must follow.
-- =====================================================================

begin;

-- recursive: users.reporting_to_id → users.id
alter table users drop constraint if exists fk_users_mgr;
alter table users drop constraint if exists users_reporting_to_id_fkey;
alter table users add constraint users_reporting_to_id_fkey
  foreign key (reporting_to_id) references users(id)
  on delete set null on update cascade;

-- departments.lead_user_id
alter table departments drop constraint if exists fk_dept_lead;
alter table departments add constraint fk_dept_lead
  foreign key (lead_user_id) references users(id)
  on delete set null on update cascade;

-- projects.owner_user_id
alter table projects drop constraint if exists projects_owner_user_id_fkey;
alter table projects add constraint projects_owner_user_id_fkey
  foreign key (owner_user_id) references users(id)
  on delete set null on update cascade;

-- user_skills.user_id
alter table user_skills drop constraint if exists user_skills_user_id_fkey;
alter table user_skills add constraint user_skills_user_id_fkey
  foreign key (user_id) references users(id)
  on delete cascade on update cascade;

-- user_skills.tagged_by
alter table user_skills drop constraint if exists user_skills_tagged_by_fkey;
alter table user_skills add constraint user_skills_tagged_by_fkey
  foreign key (tagged_by) references users(id)
  on delete set null on update cascade;

-- daily_logs.user_id
alter table daily_logs drop constraint if exists daily_logs_user_id_fkey;
alter table daily_logs add constraint daily_logs_user_id_fkey
  foreign key (user_id) references users(id)
  on delete cascade on update cascade;

-- daily_logs.assigned_by
alter table daily_logs drop constraint if exists daily_logs_assigned_by_fkey;
alter table daily_logs add constraint daily_logs_assigned_by_fkey
  foreign key (assigned_by) references users(id)
  on delete set null on update cascade;

-- audit_log.actor_user_id
alter table audit_log drop constraint if exists audit_log_actor_user_id_fkey;
alter table audit_log add constraint audit_log_actor_user_id_fkey
  foreign key (actor_user_id) references users(id)
  on delete set null on update cascade;

-- allow_list.invited_by
alter table allow_list drop constraint if exists allow_list_invited_by_fkey;
alter table allow_list add constraint allow_list_invited_by_fkey
  foreign key (invited_by) references users(id)
  on delete set null on update cascade;

-- =====================================================================
-- Now retry the retroactive link for already-signed-up users (Jayesh)
-- =====================================================================
update public.users u
   set id = a.id
  from auth.users a
 where a.email = u.email
   and u.id <> a.id;

commit;

-- Verify:  select email, role from users where role='admin' order by name;
