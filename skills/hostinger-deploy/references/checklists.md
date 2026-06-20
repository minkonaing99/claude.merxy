# Hostinger Deploy — Checklists

> Loaded by SKILL.md for `checklist`, and run inside Deploy Mode. Driver-lint gate is mandatory.

## Pre-Deploy Checklist

Run each item. Stop and fix before deploy if anything fails.

```
PRE-DEPLOY CHECKLIST
────────────────────
[ ] npm run build exits 0 (TypeScript errors = build fails = no deploy)
[ ] public_html/assets/ contains hashed filenames (e.g., main-a1b2c3d4.js)
[ ] No source maps in public_html/ (*.map files)
[ ] Images compressed (check file sizes — >200KB images need webp/avif versions)
[ ] config/.env is NOT in the rsync include list
[ ] .env is in .gitignore (run: git status — should not appear)
[ ] composer install --no-dev ran without errors
[ ] vendor/ present locally (rsync will send it)
[ ] PHP version on server ≥ 8.1 (VERIFY IN hPanel → PHP Configuration)
[ ] Opcache enabled on chosen PHP version (VERIFY IN hPanel → PHP Configuration)
[ ] HTTPS certificate active (VERIFY IN hPanel → SSL → Let's Encrypt)
[ ] DB credentials set in ~/domains/<site>/config/.env on server (SSH to verify)
[ ] Inode count below plan limit (600k; ⚠ VERIFY IN hPanel → Resource Usage)
[ ] No WebSocket / always-on daemon required (if yes → STOP, see hard stops above)

DRIVER LINT (gate — grep .env, fail loudly on any unsupported driver)
[ ] DB_CONNECTION=mysql        (NOT pgsql/sqlite — Postgres unavailable, 3 GB/DB cap)
[ ] CACHE_STORE=database|file  (NOT redis — Redis typically unavailable)
[ ] SESSION_DRIVER=database|file  (NOT redis)
[ ] QUEUE_CONNECTION=database  (NOT redis/sync-by-accident; drained by cron, see laravel.md)
    → If any line reads redis/pgsql: STOP. It will fail silently at runtime. Fix .env first.
```

---

## Post-Deploy Checklist

Run these commands after deploy.sh completes:

```bash
SITE="yourdomain.com"

# 1. Basic health check — expect HTTP 200
curl -sI "https://${SITE}/" | grep "HTTP/"

# 2. Confirm HTTPS redirect from HTTP
curl -sI "http://${SITE}/" | grep "Location:"

# 3. Confirm HSTS header present
curl -sI "https://${SITE}/" | grep -i "strict-transport"

# 4. Confirm security headers
curl -sI "https://${SITE}/" | grep -iE "x-content-type|x-frame|content-security"

# 5. LSCache HIT — run twice (first response primes cache)
curl -sI "https://${SITE}/" | grep -i "x-litespeed-cache"
curl -sI "https://${SITE}/" | grep -i "x-litespeed-cache"
# Second response should show: x-litespeed-cache: hit

# 6. .env must NOT be downloadable — expect 403 or 404
curl -so /dev/null -w "%{http_code}" "https://${SITE}/config/.env"
curl -so /dev/null -w "%{http_code}" "https://${SITE}/.env"
# Both must return 403 or 404. If 200: STOP, fix .htaccess deny rules immediately.

# 7. Hashed assets have long cache headers
ASSET_URL=$(curl -s "https://${SITE}/" | grep -oP 'assets/[^"]+\.js' | head -1)
curl -sI "https://${SITE}/${ASSET_URL}" | grep -i "cache-control"
# Should contain: max-age=31536000, immutable
```

After commands, check hPanel → Resource Usage - CPU/RAM should not spike after deploy. If they do, LSCache not warming correctly.

---
