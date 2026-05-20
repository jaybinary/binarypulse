# 📍 START HERE — Read this first every session

**Project:** BinaryPulse — internal resource utilisation & talent intelligence platform for Binary
**Sponsor:** Jayesh (jayesh@binaryic.in), Founder
**Product Head (acting):** Claude
**Started:** 20 May 2026
**Target launch:** 8 weeks from start (mid-July 2026)
**Live URL:** https://binarypulse.live (Netlify)

---

## What this product is

A multi-user web app that gives Binary leadership / HR / managers a live view of:
- Who is doing what today (utilisation)
- Who is idle (bench visibility)
- What skills the company has and is/isn't using (talent intelligence)

**Not** a project management tool (Binary uses Zoho Projects) and **not** an attendance tool (Binary uses Team Trace). Fills the gap between those two.

---

## Tech stack (locked, do not change without sponsor approval)

- **Frontend:** Next.js 14 App Router + TypeScript + Tailwind CSS
- **Backend:** Supabase (Postgres + Auth + Realtime + Edge Functions + Storage) — Mumbai region (ap-south-1)
- **Auth:** Google OAuth via Supabase, restricted to @binaryic.in via allow-list
- **Hosting:** Netlify with `@netlify/plugin-nextjs` adapter
- **Email (Phase 4):** Resend
- **Custom domain:** binarypulse.live (registered through Netlify)

---

## Where things live

| What | Where |
|---|---|
| Source code | `/Users/jayeshkhagram/Desktop/Binary Tasks/Binary Tasks/binarypulse/` |
| GitHub repo | https://github.com/jaybinary/binarypulse |
| Supabase project | `binarypulse` in BinaryIC org (URL: `https://nkpckxjkrsvoxjbernzt.supabase.co`) |
| Live site | https://binarypulse.live |
| PRD v2 | `/Binary Tasks/BinaryPulse_PRD_v2_Supabase.docx` |
| Architecture diagram | `/Binary Tasks/BinaryPulse_Architecture_v2.svg` |
| Schema (truth) | `/binarypulse/supabase/migrations/` |

---

## How to start every new session

If you (Claude) are reading this in a fresh session, follow these 5 steps before doing anything else:

1. **Read this file in full** — you're already here. Good.
2. **Read `SESSION_LOG.md`** — see what was done last session and what's next.
3. **Read `DECISIONS.md`** — understand the choices already locked in.
4. **Skim the file tree** — `find . -type f -not -path "./node_modules/*" -not -path "./.next/*" | sort` — confirm code state matches the log.
5. **Confirm with Jayesh** — briefly summarise what you understand the state to be, ask "ready to proceed with [next task]?" before writing code.

**Do not assume.** If something in the log says "done" but you can't find the code for it, ASK before re-doing it.

---

## End-of-session checklist (every session)

Before closing a session, Claude MUST:

1. ☐ Append a new entry to `SESSION_LOG.md` with today's date, what was built, files changed, decisions
2. ☐ Update `DECISIONS.md` if any architectural or product decision was made
3. ☐ Update this `CLAUDE.md` if the project state changed (e.g., launched a phase, changed stack)
4. ☐ Run `git add . && git commit -m "session N: <summary>" && git push` — code + docs to GitHub
5. ☐ Tell Jayesh what was committed and what to expect next session

---

## User profile

- Jayesh runs Binary, ~71 employees across 11 departments
- Mumbai-based, IST timezone (Asia/Kolkata)
- Non-developer — every action must be copy-paste or click
- Prefers fewer accounts and zero ongoing maintenance
- Already uses: Zoho Projects, Team Trace, Google Workspace
- Day-to-day tool: existing `Binary_Daily_Resource_Tracker_v4_GSheet` (will be retired post-launch)

---

## The 7 product decisions still pending

(From PRD v2 section 13 — Jayesh has not finalised these; default settings are in place.)

1. Standard hours variants beyond 8 / 4
2. Holiday calendar source
3. Skills taxonomy v1 — 44 drafted; needs workshop with department heads
4. Daily digest recipients list
5. Project_Master curator post-launch
6. Skills tagging policy (manager-only vs self-tag-with-approval)
7. Data retention policy

When any of these get answered, update `DECISIONS.md`.

---

*This file is the source of truth for project state. Keep it accurate.*


## Current deployment state (as of 20 May 2026)

- Code: github.com/jaybinary/binarypulse (live, all files except .gitignore — see SESSION_LOG)
- Database: Supabase Mumbai region, schema applied. 11 departments + 44 skills seeded. **User seed pending** (00002_seed_users.sql ready, awaiting Jayesh to run).
- Hosting: Netlify, building from main branch. Temporary `*.netlify.app` URL working. Custom domain `binarypulse.live` pending connection.
- Auth: email + password. Jayesh manually linked + signed up. Other users will use the auto-link trigger added in migration 00002.
- Pending immediate steps:
  1. Run `00002_seed_users.sql` in Supabase
  2. Connect `binarypulse.live` to the Netlify site
  3. Add custom domain to Supabase redirect URLs
  4. Test signup as a second user (e.g., create temp test@binaryic.in to verify the trigger works)
