# Laravel on Hostinger Business Shared Hosting

First-class deploy target. Laravel deploy model on shared hosting = **git-pull-on-server**, not the rsync flow for static/Slim sites. Different model - follow this file end to end, don't mix with `deploy.sh`.

Read Plan Specs and Hard Stops in `../SKILL.md` first. `queue:work` daemon and Reverb/websockets STOP here; `database` queue + cron and scheduler supported in degraded form (below).

> ⚠ Inode cost: Laravel app + `vendor/` = tens of thousands of files. With 600k cap, a few Laravel apps + their `vendor/` and `node_modules/` add up fast. Never upload `node_modules/`. Build assets locally, ship only `public/build`.

---

## 1. Document root — the #1 thing that breaks Laravel

Project must live **outside** `public_html`; web server must serve Laravel's `public/`. Three mechanisms, by preference.

### A. (Preferred) Point domain document root at `public/` in hPanel
hPanel → Websites → domain → **Document root** → set to `.../laravel/public`. Cleanest: no symlink, no edited `index.php`, survives backups. Use when plan exposes per-domain document root.

### B. (Portable fallback) Move `public/` contents into `public_html`, repoint `index.php`
Always works, survives backup/restore. App in `~/laravel` (sibling of `public_html`); copy contents of `laravel/public/` into `public_html/`; edit the two require paths in `public_html/index.php`:

```php
// public_html/index.php
require __DIR__.'/../laravel/vendor/autoload.php';
$app = require_once __DIR__.'/../laravel/bootstrap/app.php';
```

Re-apply this edit after any Laravel upgrade that rewrites `index.php`.

### C. Symlink (noted, not preferred)
```bash
rm -rf public_html && ln -s ~/laravel/public public_html
```
One-liner, cleanest when it holds - but some shared hosts disallow symlinked doc roots or **reset the symlink on backup restore**. If used, add a post-restore check.

---

## 2. Deploy via Git + SSH (not FTP, not rsync)

Git pull gives atomic-ish updates + instant rollback (`git reset --hard <prev>`).

```bash
# one-time, on server
cd ~ && git clone <repo-url> laravel
cd laravel
cp .env.example .env   # then edit (see driver lint), never commit real .env

# every deploy, on server
cd ~/laravel
php artisan down                       # maintenance window
git pull --ff-only
composer install --no-dev --optimize-autoloader
php artisan migrate --force            # see §4 guardrails
php artisan optimize                   # config+route+view cache
php artisan up
```

`.env` lives in `~/laravel/.env` - outside `public_html`, never in repo. Set **PHP version in hPanel before** any `artisan`/`composer` run (likely 8.3/8.4; confirm).

---

## 3. Queues & scheduler (degraded, supported)

No persistent worker. Do NOT run `queue:work` as a daemon - dies with the request/SSH session.

```dotenv
QUEUE_CONNECTION=database
```
```bash
php artisan queue:table && php artisan migrate --force   # once
```

Drain queue + run scheduler from **one cron entry** (hPanel → Cron Jobs):

```cron
* * * * * cd ~/laravel && php artisan schedule:run >> /dev/null 2>&1
```

In `app/Console/Kernel.php` (or `routes/console.php` on L11+), drive jobs from the scheduler so no daemon needed:

```php
$schedule->command('queue:work --stop-when-empty --max-time=50')->everyMinute()->withoutOverlapping();
```

`--stop-when-empty --max-time=50` makes each run finish inside the minute, so cron paces it, not a daemon. **Honesty:** minute-granularity, not real-time. Sub-second jobs, high throughput, or websockets → VPS.

---

## 4. Heavy artisan ops — shared CPU/RAM guardrails (advisory)

Large migrations + bulk imports can be **throttled or OOM-killed** mid-run on a shared box. MySQL has no transactional DDL, so a killed migration leaves a half-applied schema.

- **DB snapshot before `migrate`** (daily backups exist, but fresh manual export is cheap insurance): `mysqldump ... > pre_migrate.sql`.
- Run migrations during **low traffic**; keep `php artisan down` up across it.
- Big **data** migrations/imports: chunk them, run **manually over SSH** - never inside the deploy script, so a kill can't abort the whole deploy. `chunk()` / `LazyCollection`, batch sizes that finish in seconds.
- Watch the **3 GB/DB cap** during large imports.

---

## 4b. Schema, not seeders

Migrations are the schema - run `php artisan migrate --force` (§2). Do **not** write/run seeders (`db:seed` / `DatabaseSeeder`) for a hosting deploy; no faker/demo data on a live target. Essential baseline rows (roles, settings) go in a dedicated migration, not a seeder.

## 5. Caches, sessions, storage

- `CACHE_STORE` / `SESSION_DRIVER` → `database` or `file` (no Redis). Run cache/session table migrations if using `database`.
- `php artisan storage:link` for public uploads (symlink `public/storage` → `storage/app/public`; if symlinks restricted, copy or use mechanism B-style path).
- `php artisan optimize:clear` if a deploy ships stale cached config.

## 6. Post-deploy checks (in addition to core checklist)

- App responds 200 over HTTPS; `.env` not downloadable (403/404).
- `php artisan about` shows intended PHP version, `mysql` DB, `database`/`file` cache+session+queue.
- Cron job listed in hPanel and firing (check `schedule:run` output / a heartbeat job).
- `php artisan migrate:status` - all expected migrations ran.

---

### Honest pushback
App needs real queues, websockets/Reverb, Redis, or always-on background work → shared hosting fights you the whole way; use the **VPS plan** (root, real daemons). For standard CRUD + API + static frontend, Business plan is fine.
