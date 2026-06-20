---
name: hostinger-deploy
description: Build and deploy web projects to Hostinger Business shared hosting (LiteSpeed, CloudLinux, NVMe, MySQL/MariaDB, SSH). Scaffolds secure project structure, generates deploy.sh with rsync, deploys Laravel via git-pull-on-server, enforces resource-cheap architecture (static frontend + PHP backend), and produces pre/post-deploy checklists. Defaults to PHP backend + locally-built static frontend; Node app slots are a caveated escape hatch, never the default.
user-invocable: true
argument-hint: "[scaffold|deploy|checklist] [site-name] [--spa] [--slim] [--laravel]"
---

Senior dev, run 50+ sites on Hostinger Business shared hosting. Know every footgun: inode exhaustion, worker limits, PHP memory caps, MySQL connection pool hits, 429 storms from repeat redeploys. Every decision optimized for security, low resource use, safe redeploy.

## Plan Specs — Business Shared Hosting

Reference figures, **Business plan as of 2026-06**. Hostinger changes tiers; starting point only, **verify current values in hPanel**.

| Resource | Limit | Class |
|---|---|---|
| Storage | 50 GB NVMe | advisory |
| Inodes (file count) | 600,000 | **hard - kills deploys** |
| PHP workers (concurrent requests) | 60 | **hard - concurrency cap** |
| Databases | 150 max, **3 GB each** | **hard - per-DB cap** |
| DB engine | MySQL / MariaDB only | **hard - no PostgreSQL** |
| RAM / CPU | 3 GB / 2 cores (shared, not guaranteed) | advisory - throttled under load |
| Node.js app slots | 5 | escape hatch (see Node section) |
| Bandwidth / SSL / backups / CDN | unlimited / free / daily / free | - |

**Hard limits = enforced rules** (warn + block when project would breach). **Advisory figures** (RAM/CPU) inform guardrails, never block. PHP 8.x - pick exact version in hPanel (likely 8.3/8.4); set it **before** any server-side PHP/artisan.

## Hard Stops — Check These First

Scan project for blockers before anything else.

**STOP only on a true persistent process** (shared host recycles workers per request - no daemon survives):
- WebSockets / real-time push (Socket.IO, Laravel Reverb, Pusher *server*, SSE with held-open connections)
- Long-running `queue:work` / `horizon` daemon that must stay alive
- Node.js/Deno/Bun as **persistent server** (request-recycled Node slot is separate, caveated case - see Node section)

**If a true-daemon blocker found, output:**
```
⛔ STOP: This project requires [feature], which needs a persistent process.
Shared hosting recycles workers per-request — no daemon stays alive.
Recommendation: deploy [feature] to a VPS (DigitalOcean, Hetzner) and call it
from this site's PHP layer. Return here once the real-time layer is extracted.
```
Do not scaffold the real-time layer until resolved.

**Supported in degraded form — recipe, not STOP:**
- **Background jobs tolerant of ~1 min latency** → Laravel `database` queue driver, drained by cron. NOT real-time.
- **Scheduled tasks** → single cron entry `* * * * * php /path/artisan schedule:run` (scheduler is cron-driven here, not a daemon).
  Honesty note to emit: *"Runs at minute granularity via cron, not a live worker. Needs sub-second jobs or high throughput → VPS."*

**Flag but continue if** project references inode/worker/memory/connection limits:
- Output: `⚠ VERIFY IN hPanel: [limit] — see Plan Specs table; figures dated, confirm before relying.`

---

## Mode Detection

Pick by argument or context:

- `scaffold` or no existing project files → **Scaffold Mode**, read `references/scaffold.md`
- `deploy` or existing project → **Deploy Mode**, read `references/deploy.md`
- `checklist` → print checklists only, read `references/checklists.md`
- `--slim` flag → scaffold with Slim 4 REST API layer (see `references/scaffold.md`)
- `--laravel` flag → **Laravel = first-class target, own deploy model (git-pull-on-server, not rsync). Read `references/laravel.md`, follow it.** Warn once on inode cost; no longer gated behind "confirm intent".
- `--spa` flag → add SPA fallback in .htaccess (see `references/scaffold.md`)

> **Node.js app slots (5 available).** Not the default. Happy path = PHP backend + locally-built static frontend. Node slot runs request-recycled under Passenger/LiteSpeed - fine for stateless SSR/API endpoint, but **not** a persistent server: no websockets, no held-open sockets, no background daemons (Hard Stops above still apply). Don't scaffold a Node server by default; reach for a slot only as deliberate escape hatch, document the tradeoff.

---

## Database Setup — schema, not seeders

Preparing for hosting: **do not write DB seeding scripts**. Ship plain `schema.sql` - imports in one step via hPanel → phpMyAdmin → Import, or `mysql -u <user> -p <db> < schema.sql` over SSH. Simpler to review, simpler to apply, no app bootstrap.

- **Plain PHP / Slim**: write `db/schema.sql` (`CREATE TABLE ...`, indexes, constraints; MySQL/MariaDB syntax). No ORM migration runner, no seeders. Baseline rows = short `INSERT` block at bottom of same file - essential reference data only (roles, settings), never demo/sample.
- **Laravel**: migrations are the schema - keep them, run `php artisan migrate --force`. Do **not** write/run seeders (`db:seed`/`DatabaseSeeder`) for a hosting deploy. Baseline rows go in a migration, not a seeder.
- Never ship demo/sample/faker data to a hosting target.

---

## Reference Files — load only what the mode needs

Keep this router lean. Read the matching file **only when that mode runs** — do not preload all of them.

| Mode / need | Read |
|---|---|
| Scaffold a new project (steps, all file templates) | `references/scaffold.md` |
| Deploy an existing project, FTP/Git fallback, file manifest, summary | `references/deploy.md` |
| Pre-deploy + post-deploy checklists (driver-lint gate) | `references/checklists.md` |
| Laravel target (git-pull deploy, doc-root fix, queues, guardrails) | `references/laravel.md` |

Plan Specs, Hard Stops, Mode Detection, and the Database rule above always apply — they gate every mode.
