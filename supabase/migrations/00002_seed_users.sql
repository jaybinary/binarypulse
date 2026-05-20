-- =====================================================================
-- BinaryPulse — Seed all 71 employees + role assignments + auto-link trigger
-- Run after 00001_initial_schema.sql
-- =====================================================================

-- Helper: convenience function to fetch department id by name
-- (avoids repeating subqueries 71 times)
create or replace function dept_id(p_name text) returns bigint as $$
  select id from departments where name = p_name;
$$ language sql stable;

-- =====================================================================
-- INSERT users (id = placeholder UUID; auth signup will link real id)
-- =====================================================================

-- Note: ON CONFLICT (email) DO NOTHING keeps Jayesh's existing row untouched.

insert into users (id, email, name, department_id, designation, role, standard_hours, active) values
-- ===== Marketing Lead =====
(gen_random_uuid(), 'sneha@binaryic.in',     'Sneha Lakhani',     dept_id('Marketing Lead'), 'Head Digital',                'leadership', 8, true),
(gen_random_uuid(), 'meenakshi@binaryic.in', 'Meenakshi Lakhani', dept_id('Marketing Lead'), 'Ecommerce Success Manager',   'leadership', 8, true),

-- ===== PM Team =====
(gen_random_uuid(), 'harish@binaryic.in',   'Harish Bhatt',   dept_id('PM Team'), 'Project Management', 'manager', 8, true),
(gen_random_uuid(), 'mansi@binaryic.in',    'Mansi Rupani',   dept_id('PM Team'), 'Project Management', 'member',  8, true),
(gen_random_uuid(), 'bhushan@binaryic.in',  'Bhushan Tawde',  dept_id('PM Team'), 'Project Management', 'member',  8, true),
(gen_random_uuid(), 'nirali@binaryic.in',   'Nirali Rajgor',  dept_id('PM Team'), 'Project Management', 'member',  8, true),
(gen_random_uuid(), 'prithvi@binaryic.in',  'Prithvi Shetty', dept_id('PM Team'), 'Project Coordinator','member',  8, true),

-- ===== UI/UX =====
(gen_random_uuid(), 'sandeep@binaryic.in', 'Sandeep Wakode', dept_id('UI/UX'), 'UI/UX',                          'manager', 8, true),
(gen_random_uuid(), 'vilas@binaryic.in',   'Vilas Patil',    dept_id('UI/UX'), 'UI/UX',                          'member',  8, true),
(gen_random_uuid(), 'arya@binaryic.in',    'Arya Naik',      dept_id('UI/UX'), 'User experience design intern',  'member',  4, true),
(gen_random_uuid(), 'vipul@binaryic.in',   'Vipul Karekar', dept_id('UI/UX'), 'Marketing Team',                  'member',  8, true),
(gen_random_uuid(), 'hritik@binaryic.in',  'Hritik Ingle',   dept_id('UI/UX'), 'Marketing Team',                  'member',  8, true),

-- ===== Frontend =====
(gen_random_uuid(), 'madhav@binaryic.in',     'Madhav',        dept_id('Frontend'), 'Shopify Team', 'manager', 8, true),
(gen_random_uuid(), 'anchal@binaryic.in',     'Anchal',        dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'dhruv@binaryic.in',      'Dhruv',         dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'nimesh@binaryic.in',     'Nimesh',        dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'jaydip@binaryic.in',     'Jaydip Chadva', dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'sakshi@binaryic.in',     'Sakshi',        dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'sandesh@binaryic.in',    'Sandesh',       dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'simran@binaryic.in',     'Simran',        dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'soyeb@binaryic.in',      'Soyeb',         dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'vishal@binaryic.in',     'Vishal',        dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'prashant@binaryic.in',   'Prashant',      dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'hiral@binaryic.in',      'Hiral Patel',   dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'kartik@binaryic.in',     'Kartik',        dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'divya.r@binaryic.in',    'Divya Rojivadiya', dept_id('Frontend'), 'Shopify Team', 'member',  8, true),
(gen_random_uuid(), 'hardik@binaryic.in',     'Hardik',        dept_id('Frontend'), 'Shopify Team', 'member',  8, true),

-- ===== Backend =====
(gen_random_uuid(), 'aarti@binaryic.in',         'Aarti',         dept_id('Backend'), 'PHP Team', 'manager', 8, true),
(gen_random_uuid(), 'anjali@binaryic.in',        'Anjali',        dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'jaydeep@binaryic.in',       'Jaydeep',       dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'dolly@binaryic.in',         'Dolly',         dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'priyal@binaryic.in',        'Priyal',        dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'sandip@binaryic.in',        'Sandip Rathod', dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'tejas@binaryic.in',         'Tejas Korat',   dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'jaymin@binaryic.in',        'Jaymin',        dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'owais@binaryic.in',         'Owais',         dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'bhagyesh@binaryic.in',      'Bhagyesh',      dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'chaitanya@binaryic.in',     'Chaitanya',     dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'sujal@binaryic.in',         'Sujal',         dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'upasana@binaryic.in',       'Upasana',       dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'himanshu@binaryic.in',      'Himanshu',      dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'paritra@binaryic.in',       'Paritra Sharma',dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'mahesh@binaryic.in',        'Mahesh',        dept_id('Backend'), 'PHP Team', 'member',  8, true),
(gen_random_uuid(), 'radhika@binaryic.in',       'Radhika',       dept_id('Backend'), 'PHP Team', 'member',  8, true),

-- ===== Mobile =====
(gen_random_uuid(), 'chirag@binaryic.in',          'Chirag Ramani',    dept_id('Mobile'), 'Mobile team', 'manager', 8, true),
(gen_random_uuid(), 'shubham@binaryic.in',         'Shubham Patidar',  dept_id('Mobile'), 'Mobile team', 'member',  8, true),
(gen_random_uuid(), 'ujjawal@binaryic.in',         'Ujjawal',          dept_id('Mobile'), 'Mobile team', 'member',  8, true),
(gen_random_uuid(), 'nevil@binaryic.in',           'Nevil',            dept_id('Mobile'), 'Mobile team', 'member',  8, true),
(gen_random_uuid(), 'smit@binaryic.in',            'Smit Parmar',      dept_id('Mobile'), 'Mobile team', 'member',  8, true),
(gen_random_uuid(), 'nilesh@binaryic.in',          'Nilesh',           dept_id('Mobile'), 'Mobile team', 'member',  8, true),
(gen_random_uuid(), 'premal@binaryic.in',          'Premal',           dept_id('Mobile'), 'Mobile team', 'member',  8, true),
(gen_random_uuid(), 'chirag.s@binaryic.in',        'Chirag Sankaliya', dept_id('Mobile'), 'Mobile team', 'member',  8, true),
(gen_random_uuid(), 'daxesh@binaryic.in',          'Daxesh Prajapati', dept_id('Mobile'), 'Mobile team', 'member',  8, true),

-- ===== QA =====
(gen_random_uuid(), 'neha@binaryic.in',   'Neha Tiwari',        dept_id('QA'), 'QA Tester', 'manager', 8, true),
(gen_random_uuid(), 'sangam@binaryic.in', 'Sangam Vishwakarma', dept_id('QA'), 'QA Tester', 'member',  8, true),

-- ===== Catalog =====
(gen_random_uuid(), 'shivam@binaryic.in', 'Shivam Vishwakarma', dept_id('Catalog'), 'Catalogue', 'manager', 8, true),
(gen_random_uuid(), 'sunita@binaryic.in', 'Sunita Yadav',       dept_id('Catalog'), 'Catalogue', 'member',  8, true),

-- ===== Digital Marketing =====
(gen_random_uuid(), 'vaishnavi@binaryic.in', 'Vaishnavi Rawalekar', dept_id('Digital Marketing'), 'Marketing Team', 'member', 8, true),
(gen_random_uuid(), 'shruti@binaryic.in',    'Shruti Gholap',       dept_id('Digital Marketing'), 'Marketing Team', 'member', 8, true),
(gen_random_uuid(), 'aditya@binaryic.in',    'Aditya Kurup',        dept_id('Digital Marketing'), 'Marketing Team', 'member', 8, true),
(gen_random_uuid(), 'shilpa@binaryic.in',    'Shilpa Kamble',       dept_id('Digital Marketing'), 'Marketing Team', 'member', 8, true),
(gen_random_uuid(), 'manasvi@binaryic.in',   'Manasvi Daftary',     dept_id('Digital Marketing'), 'Marketing Team', 'member', 8, true),
(gen_random_uuid(), 'tanmay@binaryic.in',    'Tanmay Pawar',        dept_id('Digital Marketing'), 'Marketing Team', 'member', 8, true),
(gen_random_uuid(), 'siddhesh@binaryic.in',  'Siddhesh Patil',      dept_id('Digital Marketing'), 'Marketing Team', 'member', 8, true),
(gen_random_uuid(), 'anooj@binaryic.in',     'Anooj Kadam',         dept_id('Digital Marketing'), 'Marketing Team', 'member', 8, true),
(gen_random_uuid(), 'sanskar@binaryic.in',   'Sanskar Jaiswal',     dept_id('Digital Marketing'), 'Marketing Team', 'member', 8, true),
(gen_random_uuid(), 'divya.w@binaryic.in',   'Divya Wakode',        dept_id('Digital Marketing'), 'Marketing Team', 'member', 8, true),

-- ===== HR/Admin (Jayesh already inserted in 00001) =====
(gen_random_uuid(), 'priyanka@binaryic.in', 'Priyanka Patel',  dept_id('HR/Admin'), 'HR Manager',         'admin', 8, true),
(gen_random_uuid(), 'manthan@binaryic.in',  'Manthan Sagalia', dept_id('HR/Admin'), 'Jr. HR Executive',   'hr',    8, true),
(gen_random_uuid(), 'prachi@binaryic.in',   'Prachi Rupani',   dept_id('HR/Admin'), 'HR Executive',       'hr',    8, true),

-- ===== Accounts =====
(gen_random_uuid(), 'nagesh@binaryic.in', 'Nagesh', dept_id('Accounts'), 'Sr. Account Executive', 'manager', 8, true),
(gen_random_uuid(), 'sejal@binaryic.in',  'Sejal',  dept_id('Accounts'), 'Jr. Account Executive', 'member',  8, true)

on conflict (email) do nothing;

-- =====================================================================
-- WIRE UP reporting_to_id (manager relationships) using email lookups
-- =====================================================================
-- After all rows exist, set each member's manager based on department lead.

update users m set reporting_to_id = (select id from users where email='harish@binaryic.in')
  where department_id = dept_id('PM Team') and role = 'member';

update users m set reporting_to_id = (select id from users where email='sandeep@binaryic.in')
  where department_id = dept_id('UI/UX') and role = 'member';

update users m set reporting_to_id = (select id from users where email='madhav@binaryic.in')
  where department_id = dept_id('Frontend') and role = 'member';

update users m set reporting_to_id = (select id from users where email='aarti@binaryic.in')
  where department_id = dept_id('Backend') and role = 'member';

update users m set reporting_to_id = (select id from users where email='chirag@binaryic.in')
  where department_id = dept_id('Mobile') and role = 'member';

update users m set reporting_to_id = (select id from users where email='neha@binaryic.in')
  where department_id = dept_id('QA') and role = 'member';

update users m set reporting_to_id = (select id from users where email='shivam@binaryic.in')
  where department_id = dept_id('Catalog') and role = 'member';

update users m set reporting_to_id = (select id from users where email='sneha@binaryic.in')
  where department_id = dept_id('Digital Marketing') and role = 'member';

update users m set reporting_to_id = (select id from users where email='nagesh@binaryic.in')
  where department_id = dept_id('Accounts') and role = 'member';

-- HR team reports to Priyanka
update users m set reporting_to_id = (select id from users where email='priyanka@binaryic.in')
  where department_id = dept_id('HR/Admin') and email <> 'priyanka@binaryic.in' and email <> 'jayesh@binaryic.in';

-- Managers and leadership report to Jayesh
update users m set reporting_to_id = (select id from users where email='jayesh@binaryic.in')
  where role in ('manager','leadership','admin','hr') and email <> 'jayesh@binaryic.in';

-- =====================================================================
-- WIRE UP department leads (departments.lead_user_id)
-- =====================================================================
update departments set lead_user_id = (select id from users where email='sneha@binaryic.in')   where name='Marketing Lead';
update departments set lead_user_id = (select id from users where email='harish@binaryic.in')  where name='PM Team';
update departments set lead_user_id = (select id from users where email='sandeep@binaryic.in') where name='UI/UX';
update departments set lead_user_id = (select id from users where email='madhav@binaryic.in')  where name='Frontend';
update departments set lead_user_id = (select id from users where email='aarti@binaryic.in')   where name='Backend';
update departments set lead_user_id = (select id from users where email='chirag@binaryic.in')  where name='Mobile';
update departments set lead_user_id = (select id from users where email='neha@binaryic.in')    where name='QA';
update departments set lead_user_id = (select id from users where email='shivam@binaryic.in')  where name='Catalog';
update departments set lead_user_id = (select id from users where email='sneha@binaryic.in')   where name='Digital Marketing';
update departments set lead_user_id = (select id from users where email='priyanka@binaryic.in')where name='HR/Admin';
update departments set lead_user_id = (select id from users where email='nagesh@binaryic.in')  where name='Accounts';

-- =====================================================================
-- AUTO-LINK TRIGGER: when a person signs up, match their email
-- to the pre-existing public.users row and replace the placeholder id
-- with their real auth.users.id.
-- =====================================================================

create or replace function public.link_auth_to_app_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.users
     set id = new.id
   where email = new.email
     and id <> new.id;       -- only update if not already linked
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.link_auth_to_app_user();

-- =====================================================================
-- For any auth users that ALREADY signed up before this trigger existed
-- (e.g., Jayesh), link them retroactively by email.
-- =====================================================================
update public.users u
   set id = a.id
  from auth.users a
 where a.email = u.email
   and u.id <> a.id;

-- =====================================================================
-- DONE. Verify with:  select email, role, designation from users order by role, name;
-- =====================================================================
