# Hostinger Deploy — Deploy Mode

> Loaded by SKILL.md for `deploy` / existing project. Run checklists from references/checklists.md.

## Deploy Mode (existing project)

Project already exists, user says "deploy" or runs against existing scaffold:

1. **Run pre-deploy checklist** (below). Stop if any item fails.
2. Run build:
   ```bash
   npm ci && npm run build && composer install --no-dev --optimize-autoloader --classmap-authoritative
   ```
3. Verify build output in `public_html/assets/` with hashed filenames.
4. Run `bash deploy.sh` (or print exact command with env vars filled in).
5. Run post-deploy checklist.

**Retry policy:** deploy.sh fails → diagnose cause first. Don't re-run immediately. Fix cause, run once. Forced auto-retry: back off 30s, 60s, 120s. Never loop.

---

## FTP / hPanel Git Fallback (no SSH access)

Document clearly when user can't use SSH:

### Option A: hPanel Git Deployment
1. hPanel → Git → connect repo.
2. Set deploy branch (e.g., `main`).
3. **Set deploy path to `public_html/` only** - never deploy whole repo root.
4. Add `.cpanel.yml` or hPanel deploy hook to run `composer install --no-dev` after pull.
5. Exclude `node_modules/`, `src/`, `config/.env`, `tests/` in `.gitignore`; confirm hPanel respects them.
6. **Risk:** hPanel Git pulls whole branch - harder to exclude files reliably. Prefer SSH+rsync.

### Option B: FTP (FileZilla / Cyberduck)
1. Build locally first: `npm run build && composer install --no-dev --optimize-autoloader`.
2. Upload `public_html/` contents → remote `public_html/`.
3. Upload `app/` → remote `app/`.
4. Upload `vendor/` → remote `vendor/`.
5. **Never upload:** `src/`, `node_modules/`, `config/.env`, `tests/`, `*.sh`, `*.map`.
6. FTP has no atomic deploy - partial uploads cause errors. Deploy during low-traffic windows.

---

## Exact File List Sent to Server

Print this table so user knows exactly what lands on server:

```
SENT TO SERVER:
  public_html/
    index.php (or index.html)
    .htaccess
    assets/main-[hash].js
    assets/main-[hash].css
    assets/[other-hashed-assets]

  app/
    bootstrap.php
    Database.php
    (routes/, controllers/ if Slim)

  vendor/
    (Composer autoload + production dependencies only)

NOT SENT (excluded):
  src/               → TypeScript source, not needed at runtime
  node_modules/      → dev tooling
  config/.env        → secrets stay on server, set manually via SSH
  tests/             → dev only
  *.map              → source maps (security + inode waste)
  *.sh               → deploy scripts
  .git/              → version history
```

---

## Output Summary

On skill completion, print:

```
HOSTINGER DEPLOY — SUMMARY
══════════════════════════
Site:          <site-name>
Frontend:      TypeScript + Vite → hashed static JS/CSS in public_html/assets/
Backend:       PHP 8.x (plain / Slim / Laravel) in app/
Database:      MySQL/MariaDB via PDO prepared statements
Secrets:       config/.env — set on server via SSH, never uploaded
Deploy method: deploy.sh (rsync over SSH)

FILES CREATED:
  vite.config.ts, package.json, tsconfig.json
  composer.json
  src/main.ts, src/style.css
  app/bootstrap.php, app/Database.php
  config/.env.example
  public_html/index.php, public_html/.htaccess
  deploy.sh
  .gitignore

NEXT STEPS:
  1. npm install && composer install
  2. Copy config/.env.example → config/.env on the server (via SSH), fill in DB creds
  3. npm run build (verify it passes)
  4. bash deploy.sh (set SITE_NAME, SSH_USER, SSH_HOST env vars first)
  5. Run post-deploy checklist above
```
