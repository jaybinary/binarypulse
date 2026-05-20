# Session Log — BinaryPulse

Append-only. Every session ends with a new entry at the top.
Newest entries first.

---

## Session 2 — 20 May 2026 — Scaffold build

**Mid-session update — auth method pivoted:**
- Discovered Binary uses Zoho Mail (not Google Workspace) for @binaryic.in addresses.
- Replaced Google OAuth flow with email + password (Jayesh's preference over magic link).
- New pages added: `app/signup/page.tsx`, `app/forgot-password/page.tsx`, `app/reset-password/page.tsx`.
- Updated `app/login/page.tsx` (now email/password form), `lib/supabase/middleware.ts` (more public routes), `README.md`.
- Google Cloud Console setup is no longer needed — skipping that entirely.
- Resend SMTP integration deferred to v1.5 (default Supabase sender works for testing).


**Mid-session update — env var convention change:**
- Switched from legacy Supabase key naming (`NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`) to new format (`NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`).
- Updated `.env.example`, `lib/supabase/client.ts`, `lib/supabase/server.ts`, `lib/supabase/middleware.ts`, `README.md`.
- Reason: Supabase introduced new API key format. New projects should use `sb_publishable_*` and `sb_secret_*`.
- Secret key exposure incident: Jayesh briefly pasted secret key in chat. Mitigation: rotated immediately via Supabase dashboard. Old key is dead.


**What was built:**
- Next.js 14 App Router project scaffolded in `binarypulse/`
- 23 files committed: package.json, configs, app routes, Supabase clients, middleware
- Postgres schema (12 tables + RLS + 44 seed skills + 11 departments) ready as migration
- README with full step-by-step deployment runbook
- Google OAuth flow wired (login page → callback route → dashboard)
- Allow-list enforcement via RLS — non-enrolled users see a "Not on the allow-list" screen
- Project continuity system created: CLAUDE.md, SESSION_LOG.md, DECISIONS.md

**Files added:**
```
binarypulse/
├── CLAUDE.md, SESSION_LOG.md, DECISIONS.md   (this continuity system)
├── README.md                                  (deployment runbook)
├── package.json, tsconfig.json, next.config.mjs, tailwind.config.ts
├── postcss.config.mjs, netlify.toml
├── .gitignore, .env.example
├── middleware.ts
├── app/
│   ├── layout.tsx, page.tsx, globals.css
│   ├── login/page.tsx
│   ├── auth/callback/route.ts
│   ├── auth/signout/route.ts
│   └── dashboard/page.tsx
├── components/nav.tsx
├── lib/
│   ├── supabase/{client,server,middleware}.ts
│   └── types.ts
└── supabase/migrations/00001_initial_schema.sql
```

**Decisions made this session:**
- Pivoted from Laravel+Railway (PRD v1) to Next.js+Supabase+Netlify (PRD v2)
- Email provider: Resend (free tier, 3k emails/month)
- Domain: binarypulse.live (registered through Netlify, replaces pulse.binaryic.in)
- Supabase region: Mumbai (ap-south-1) — switched from initial Tokyo selection for latency
- Established 4-layer continuity system (CLAUDE.md + SESSION_LOG.md + DECISIONS.md + GitHub)

**Pending at end of session:**
- ⏳ Supabase project finishes provisioning (status was "Coming up…")
- ⏳ Jayesh to share Supabase anon public key
- ⏳ Jayesh to apply schema in Supabase SQL Editor
- ⏳ Jayesh to push code to GitHub (commands in README step 1)
- ⏳ Jayesh to import repo into Netlify and set env vars
- ⏳ Jayesh to wire custom domain and test login

**Next session (Session 3) — when Jayesh returns with deployed URL + login working:**
- Build the Daily Check-in form (most-used screen, mobile-first, <30s entry target)
- Build My Dashboard (own log history + variance trend)
- Add auto-trigger to link auth.users.id → public.users.id on first login

**Blockers / open questions:**
- None blocking — Jayesh has clear next steps in README

---

