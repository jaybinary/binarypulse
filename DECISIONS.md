# Decisions Log — BinaryPulse

Every architectural, product, and stack decision with its date and rationale.
Decisions here are LOCKED unless explicitly revisited with sponsor sign-off.

---

## ADR-006 — 20 May 2026 — Project continuity system
**Status:** Active
**Decision:** Use CLAUDE.md + SESSION_LOG.md + DECISIONS.md in the repo, plus internal Claude persistent memory, plus GitHub as ultimate backup. Every session ends with commit + push.
**Why:** Multi-session project. Individual Claude chat sessions don't persist memory across days. Files in the repo are version-controlled and survive forever.
**Implication:** Every session MUST end with `git commit && git push` and SESSION_LOG.md update.

## ADR-005 — 20 May 2026 — Domain: binarypulse.live
**Status:** Active
**Decision:** Use `binarypulse.live` (registered through Netlify) instead of original `pulse.binaryic.in`.
**Why:** Jayesh registered binarypulse.live directly. Removes DNS dependency on the binaryic.in registrar. Cleaner brand.
**Cost:** $41.99/year (Netlify registrar).

## ADR-004 — 20 May 2026 — Email provider: Resend
**Status:** Active
**Decision:** Use Resend over AWS SES for transactional email (daily digest, reminders, alerts).
**Why:** Free tier (3,000 emails/month, 100/day) covers BinaryPulse's projected ~2,800 emails/month. Setup is 10 minutes vs 24–72hr sandbox-lift for AWS SES. Migration to SES is ~30 lines of code if scale demands.
**Volume estimate:** 71 daily digests × 26 working days + 500 ad-hoc + 50 weekly/monthly = ~2,800/month.

## ADR-003 — 20 May 2026 — Supabase region: Mumbai
**Status:** Active
**Decision:** Provision the Supabase project in South Asia (Mumbai, ap-south-1).
**Why:** Binary team is India-based. Latency to Mumbai is ~10–30ms vs ~120ms to Tokyo. Critical for realtime dashboard subscriptions.
**Note:** Jayesh's first project was in Tokyo; recreated in Mumbai on advice.

## ADR-002 — 20 May 2026 — Hosting: Netlify (not Vercel)
**Status:** Active
**Decision:** Host the Next.js frontend on Netlify using `@netlify/plugin-nextjs`.
**Why:** Jayesh's preference (vs default Vercel). Both work; Netlify chosen on user familiarity.
**Implication:** `netlify.toml` configured. Build adapter handles Next.js 14 App Router routes.

## ADR-001 — 20 May 2026 — Stack: Next.js + Supabase (not Laravel + Railway)
**Status:** Active — supersedes original Laravel plan
**Decision:** Build BinaryPulse as Next.js 14 + TypeScript + Supabase (Postgres + Auth + Realtime + Edge Functions) instead of Laravel + React + MySQL on Railway.
**Why:**
- Jayesh's constraint: "develop via Claude only, don't touch anyone." Supabase removes ~40% of backend code via Row Level Security.
- 8-week build vs 12-week.
- ₹0/month at scale vs ~₹500/month.
- Less code to maintain across sessions.
- Realtime built in (live dashboards without polling).
**Trade-off accepted:** Loses Laravel ecosystem; bound to Supabase platform (standard Postgres underneath mitigates lock-in).

---

## Decisions still pending (from PRD v2 section 13)

1. Standard hours variants beyond 8 / 4 — TBD
2. Holiday calendar — TBD (default: skip Sundays, no public holidays yet)
3. Skills taxonomy v1 — 44 drafted, needs workshop signoff
4. Daily digest recipients — TBD (default: only Jayesh)
5. Project_Master curator post-launch — TBD (default: Admin)
6. Skills tagging policy — TBD (default: manager-tagged + self-tag-with-approval)
7. Data retention — TBD (default: forever)

When any of these get decided, move the line up to a new ADR with date.

## ADR-007 — 20 May 2026 — Use new Supabase API key format
**Status:** Active
**Decision:** Use the new `sb_publishable_*` and `sb_secret_*` API key format instead of legacy `anon` / `service_role` JWTs.
**Why:** Supabase introduced the new format with better scoping and rotation. Recommended in the dashboard for new projects.
**Env var names:** `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (frontend), `SUPABASE_SECRET_KEY` (backend).
**Note:** `@supabase/ssr` works identically with both formats — this is purely a naming/convention choice.

## ADR-008 — 20 May 2026 — Secret rotation on accidental exposure
**Status:** Active policy
**Decision:** If any production secret (Supabase secret key, Resend API key, Netlify env, etc.) appears in chat by accident, rotate it immediately via the issuing service's dashboard before continuing.
**Why:** Standard secrets hygiene. The old key is dead, the new key is unknown to anyone outside the dashboard.
**Trigger:** Happened on 20 May 2026 — handled correctly.

## ADR-009 — 20 May 2026 — Auth method: Email + Password (not Google OAuth)
**Status:** Active — supersedes earlier Google OAuth plan
**Decision:** Use email + password authentication via Supabase Auth's native email provider, not Google OAuth.
**Why:** Binary uses Zoho Mail for @binaryic.in addresses, not Google Workspace. There is no Google account behind each employee's work email, so OAuth via Google would have failed.
**Alternatives considered:**
- Magic Link (passwordless): rejected by Jayesh in favour of familiar password UX.
- Zoho SSO (SAML): requires Supabase Pro tier, overkill for v1.
**Implication:** Removes Google Cloud Console dependency entirely. Signup, login, forgot-password, reset-password pages built. Email templates default to Supabase sender until Resend SMTP is configured (planned for v1.5).
