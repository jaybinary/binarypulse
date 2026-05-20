# BinaryPulse

Resource utilisation & talent intelligence platform for Binary.
Internal tool. Restricted to allow-listed @binaryic.in accounts.

**Stack:** Next.js 14 (App Router) · TypeScript · Tailwind · Supabase (Postgres + Auth + Realtime) · Netlify hosting.

---

## ⚡ One-time setup (do these ONCE in order)

You will copy-paste from this README. No coding required.

### 1. Push this folder to GitHub

Open a terminal in this folder and run:

```bash
git init -b main
git add .
git commit -m "scaffold v0.1"
git remote add origin https://github.com/jaybinary/binarypulse.git
git push -u origin main
```

If you don't have `git` installed → install Git for Mac from https://git-scm.com/download/mac (one click).

### 2. Apply the database schema to Supabase

1. Open https://supabase.com/dashboard → project **binarypulse**.
2. Left sidebar → **SQL Editor** → **New query**.
3. Open `supabase/migrations/00001_initial_schema.sql` in this folder, copy ALL of it.
4. Paste into the SQL editor → click **Run**.
5. You should see "Success. No rows returned" — schema is now live.
6. Verify: sidebar → **Table Editor** — you should see ~12 tables (users, departments, projects, skills, etc.).

### 3. Configure Supabase Auth (email + password)

We use email + password sign-in because @binaryic.in is hosted on Zoho Mail (not Google Workspace).

1. Supabase dashboard → **Authentication** → **Sign In / Up** (or **Providers**).
2. Make sure **Email** provider is enabled (it is by default).
   - Confirm email is ON for production. OFF can be useful during dev so you don't need to click links.
3. Authentication → **URL Configuration**:
   - **Site URL:** `https://binarypulse.live`
   - **Redirect URLs (allow list):** add all three:
     ```
     https://binarypulse.live/auth/callback
     https://binarypulse.live/reset-password
     https://*.netlify.app/auth/callback
     http://localhost:3000/auth/callback
     ```
4. Authentication → **Emails**: review the email templates. They'll work with Supabase's default sender for testing; we'll plug in Resend SMTP in step 8 for production-quality emails.

### 4. Add yourself to the users table (bootstrap admin)

Supabase → **SQL Editor** → new query → paste:

```sql
-- Replace email if different
insert into users (id, email, name, department_id, designation, role, standard_hours)
select gen_random_uuid(), 'jayesh@binaryic.in', 'Jayesh',
       (select id from departments where name='HR/Admin'),
       'Founder', 'admin', 8
on conflict (email) do nothing;
```

When you first log in, the app will link your real Supabase auth.users.id to this row (we'll automate this in Phase 2 with a trigger; for now, you may need to update the row to your real auth user id once known).

### 5. Connect Netlify to the repo

1. Go to https://app.netlify.com → **Add new site** → **Import from Git**.
2. Pick GitHub → **jaybinary/binarypulse**.
3. Build settings should auto-detect from `netlify.toml`:
   - Build command: `npm run build`
   - Publish directory: `.next`
4. **Environment variables** (click "Add environment variables" before deploying):
   - `NEXT_PUBLIC_SUPABASE_URL` = `https://nkpckxjkrsvoxjbernzt.supabase.co`
   - `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` = (your sb_publishable_xxx... key from Supabase → Project Settings → API → Publishable and secret API keys)
   - `SUPABASE_SECRET_KEY` = (your sb_secret_xxx... key — paste here ONLY, never in chat or git)
   - `NEXT_PUBLIC_SITE_URL` = `https://binarypulse.live`
5. Click **Deploy site**. First build takes 2–3 minutes.

### 6. Wire up the custom domain

1. In Netlify → your new site → **Domain management** → **Add custom domain** → enter `binarypulse.live`.
2. Since the domain is already registered through Netlify, click **Yes, add domain** — DNS auto-configures.
3. Netlify will provision a free SSL certificate within ~1 minute.

### 7. Test the login flow

1. Open `https://binarypulse.live`.
2. Click **Create one** → sign up with jayesh@binaryic.in + a password.
3. Check your Zoho inbox for the confirmation email → click the link.
4. Come back to the site → sign in.
5. You should land on `/dashboard` with your name + admin role visible.
6. If you see "Not on the allow-list" — the trigger that links auth.users → public.users didn't fire. Tell me and I'll add a manual SQL fix.

### 8. (Optional but recommended) Plug Resend in as SMTP

By default Supabase sends emails from its own domain — these often land in spam, and have a low rate limit. For production we route through Resend so confirmation/reset emails come from `noreply@binarypulse.live`.

1. Verify `binarypulse.live` in Resend (their dashboard gives you 3 DNS records to add in Netlify DNS).
2. Once verified, in Resend create an **API key** (it'll start with `re_`).
3. Resend → **SMTP** tab → copy the SMTP credentials.
4. Supabase → **Project Settings → Auth → SMTP Settings** → Enable custom SMTP and paste:
   - Host: `smtp.resend.com`
   - Port: `465`
   - User: `resend`
   - Pass: your Resend API key
   - Sender email: `noreply@binarypulse.live`
   - Sender name: `BinaryPulse`
5. Save and test by triggering a password reset.

---

## 🏃 Local development (optional)

```bash
cp .env.example .env.local
# Edit .env.local with the real Supabase URL + anon key

npm install
npm run dev
```

Visit http://localhost:3000. Make sure `http://localhost:3000/auth/callback` is in your Supabase redirect URLs (step 3).

---

## 📁 Project structure

```
binarypulse/
├── app/
│   ├── layout.tsx              # root layout
│   ├── page.tsx                # redirects to /dashboard
│   ├── login/page.tsx          # email + password sign-in
│   ├── signup/page.tsx         # new user creation
│   ├── forgot-password/page.tsx # request reset email
│   ├── reset-password/page.tsx  # set a new password (from reset email)
│   ├── auth/
│   │   ├── callback/route.ts   # confirms email after signup / reset
│   │   └── signout/route.ts    # sign out handler
│   └── dashboard/page.tsx      # post-login landing
├── components/
│   └── nav.tsx                 # top navigation bar
├── lib/
│   ├── supabase/
│   │   ├── client.ts           # browser-side client
│   │   ├── server.ts           # server-side client (RSC + routes)
│   │   └── middleware.ts       # session refresh + route guards
│   └── types.ts                # shared TypeScript types
├── supabase/
│   └── migrations/
│       └── 00001_initial_schema.sql   # 12 tables + RLS + seed
├── middleware.ts               # Next.js middleware (auth gate)
├── netlify.toml                # build config for Netlify
├── tailwind.config.ts
├── tsconfig.json
├── next.config.mjs
├── package.json
└── README.md (this file)
```

---

## 🛣️ What's next (sessions 3–8)

| Week | Module | Files added |
|---|---|---|
| 2 | Daily check-in form, My Dashboard | `app/checkin/`, `app/me/` |
| 3 | Manager + Leadership dashboards | `app/team/`, `app/org/` |
| 4 | Talent Intelligence — skills matrix | `app/talent/` |
| 5 | HR + Admin modules | `app/hr/`, `app/admin/` |
| 6 | Daily digest, Slack, Zoho, Team Trace | `supabase/functions/` |
| 7 | Pilot with PM Team | bug fixes |
| 8 | Org-wide launch | training + docs |

---

## 🆘 Troubleshooting

- **Build fails on Netlify**: check `NODE_VERSION = "20"` is set. Look at the Netlify build log; most issues are missing env vars.
- **Login spins forever**: Google provider not enabled in Supabase, or redirect URL missing.
- **"Not on the allow-list"**: your auth.users.id needs a matching row in the public.users table. We'll automate this; for now, ask Jayesh to insert manually.
- **RLS denying everything**: confirm the policies in the schema executed without errors.

---

Built session-by-session with Claude as Product Head. Each commit is a working build.
