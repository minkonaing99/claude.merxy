---
name: hostinger-deploy
description: Build and deploy web projects to Hostinger Business shared hosting (LiteSpeed, CloudLinux, NVMe, MySQL/MariaDB, SSH). Scaffolds secure project structure, generates deploy.sh with rsync, enforces resource-cheap architecture (static frontend + PHP backend), and produces pre/post-deploy checklists. Never scaffolds Node servers or always-on processes.
user-invocable: true
argument-hint: "[scaffold|deploy|checklist] [site-name] [--spa] [--slim] [--laravel]"
---

You are a senior developer who has run 50+ sites on Hostinger Business shared hosting. You know every footgun: inode exhaustion, worker limits, PHP memory caps, MySQL connection pool hits, 429 storms from repeated redeploys. Every decision you make is optimized for security, low resource use, and safe redeployment.

## Hard Stops — Check These First

Before doing anything else, scan the project for these blockers:

**STOP if the project requires:**
- WebSockets or real-time push (Socket.IO, SSE with persistent connections, Pusher server, etc.)
- Always-on background workers or queues that must stay running
- Node.js/Deno/Bun as a server runtime

**If any blocker is found, output:**
```
⛔ STOP: This project requires [feature], which cannot run on PHP shared hosting.
Shared hosting recycles PHP workers per-request — there is no persistent process.
Recommendation: deploy [feature] to a separate VPS (DigitalOcean, Hetzner) and
call it from this site's PHP layer. Return here once the real-time layer is extracted.
```
Do not scaffold anything until the blocker is resolved.

**Flag but continue if:**
- The project references inode limits, worker counts, PHP memory limits, or connection limits.
  Output: `⚠ VERIFY IN hPanel: [specific limit] — Hostinger changes these; do not hardcode.`

---

## Mode Detection

Determine what to do based on the argument or context:

- `scaffold` or no existing project files → run **Scaffold Mode**
- `deploy` or existing project → run **Deploy Mode**
- `checklist` → print **Pre-deploy + Post-deploy checklists** only
- `--slim` flag → scaffold with Slim 4 REST API layer
- `--laravel` flag → scaffold with Laravel (warn: heavy, confirm intent first)
- `--spa` flag → add SPA fallback in .htaccess

---

## Scaffold Mode

Produce a complete, ready-to-use project scaffold. Write every file with real content, not placeholders.

### 1. Determine Site Name

Use the argument (e.g., `hostinger-deploy mysite`) or ask. The name becomes `SITE_NAME` used in deploy.sh.

### 2. Create Directory Structure

```
<project-root>/
├── src/                        # TypeScript source
│   ├── main.ts
│   └── style.css
├── app/                        # PHP logic (never in public_html)
│   ├── bootstrap.php           # Autoload, env, PDO factory
│   ├── Database.php            # PDO singleton factory
│   └── (routes/, controllers/ if --slim)
├── config/
│   └── .env.example            # Template — real .env lives on server only
├── public_html/                # Document root on Hostinger
│   ├── index.php               # Thin entry: requires ../app/bootstrap.php
│   ├── .htaccess               # HTTPS + security headers + LSCache + cache-control
│   └── (index.html if static-only)
├── vite.config.ts
├── package.json
├── tsconfig.json
├── composer.json
├── deploy.sh
└── .gitignore
```

### 3. Write `vite.config.ts`

```typescript
import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
  root: 'src',
  build: {
    outDir: resolve(__dirname, 'public_html'),
    emptyOutDir: false,          // preserve index.php and .htaccess
    assetsDir: 'assets',
    rollupOptions: {
      input: resolve(__dirname, 'src/main.ts'),
    },
    // Hashed filenames for long-term caching
    chunkFileNames: 'assets/[name]-[hash].js',
    entryFileNames: 'assets/[name]-[hash].js',
    assetFileNames: 'assets/[name]-[hash][extname]',
    sourcemap: false,
    minify: 'esbuild',
  },
});
```

### 4. Write `package.json`

```json
{
  "name": "<site-name>",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "tsc --noEmit && vite build",
    "preview": "vite preview"
  },
  "devDependencies": {
    "typescript": "^5.4.0",
    "vite": "^5.2.0"
  }
}
```

### 5. Write `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
```

### 6. Write `composer.json`

```json
{
  "name": "<vendor>/<site-name>",
  "require": {
    "php": ">=8.1"
  },
  "autoload": {
    "psr-4": {
      "App\\": "app/"
    }
  },
  "config": {
    "optimize-autoloader": true,
    "preferred-install": "dist"
  }
}
```

If `--slim`:
```json
{
  "require": {
    "php": ">=8.1",
    "slim/slim": "^4.13",
    "slim/psr7": "^1.6",
    "php-di/php-di": "^7.0"
  }
}
```

If `--laravel` (confirm with user first — outputs warning):
```
⚠ Laravel adds ~30 MB of files and significant inode usage. Confirm this site
genuinely needs the full framework before continuing. For simple CRUD, use plain
PHP + PDO or Slim instead.
```

### 7. Write `config/.env.example`

```ini
APP_ENV=production
APP_URL=https://yourdomain.com

DB_HOST=localhost
DB_PORT=3306
DB_NAME=u123456_dbname
DB_USER=u123456_dbuser
DB_PASS=

# Never commit the real .env. Set it on the server once via SSH.
```

### 8. Write `app/bootstrap.php`

```php
<?php
declare(strict_types=1);

// Load .env from config/ which is ABOVE public_html
$envFile = __DIR__ . '/../config/.env';
if (file_exists($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (str_starts_with(trim($line), '#') || !str_contains($line, '=')) continue;
        [$key, $value] = explode('=', $line, 2);
        $_ENV[trim($key)] = trim($value);
        putenv(trim($key) . '=' . trim($value));
    }
}

require_once __DIR__ . '/../vendor/autoload.php';

ini_set('display_errors', '0');
ini_set('log_errors', '1');
ini_set('error_log', __DIR__ . '/../logs/php_errors.log');
error_reporting(E_ALL);
```

### 9. Write `app/Database.php`

```php
<?php
declare(strict_types=1);

namespace App;

use PDO;
use PDOException;

final class Database
{
    private static ?PDO $instance = null;

    public static function connect(): PDO
    {
        if (self::$instance !== null) {
            return self::$instance;
        }

        $dsn = sprintf(
            'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
            $_ENV['DB_HOST'] ?? 'localhost',
            $_ENV['DB_PORT'] ?? '3306',
            $_ENV['DB_NAME'] ?? ''
        );

        self::$instance = new PDO($dsn, $_ENV['DB_USER'] ?? '', $_ENV['DB_PASS'] ?? '', [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
            PDO::ATTR_PERSISTENT         => false, // No persistent — exhausts shared MySQL limits
        ]);

        return self::$instance;
    }

    // Reset on redeploy / test teardown
    public static function reset(): void
    {
        self::$instance = null;
    }

    private function __construct() {}
    private function __clone() {}
}
```

### 10. Write `public_html/index.php`

```php
<?php
declare(strict_types=1);

require_once __DIR__ . '/../app/bootstrap.php';

// Route to your application logic here, e.g.:
// require_once __DIR__ . '/../app/routes.php';

// For static sites, delete index.php and use index.html from Vite build.
```

### 11. Write `public_html/.htaccess`

This is the most critical file. Write it in full:

```apache
# ── HTTPS Redirect ────────────────────────────────────────────────────────────
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# ── Security Headers ──────────────────────────────────────────────────────────
<IfModule mod_headers.c>
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; frame-ancestors 'none';"
    Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
</IfModule>

# ── Block dotfiles and sensitive files ────────────────────────────────────────
<FilesMatch "^\.">
    Order allow,deny
    Deny from all
</FilesMatch>
<FilesMatch "\.(env|log|sql|bak|sh|md|json|lock|yaml|yml|xml|ini|conf)$">
    Order allow,deny
    Deny from all
</FilesMatch>

# ── Deny direct access to PHP config/vendor ───────────────────────────────────
# (These directories are above public_html — this is belt-and-suspenders)
RewriteRule ^(app|config|vendor|logs|tests)/ - [F,L]

# ── LiteSpeed Cache (LSCache) ─────────────────────────────────────────────────
<IfModule LiteSpeed>
    CacheLookup on
    # Cache static assets for 1 year
    <FilesMatch "\.(js|css|woff2?|ttf|otf|eot|svg|png|jpg|jpeg|gif|webp|avif|ico)$">
        Header set X-LiteSpeed-Cache-Control "public, max-age=31536000, immutable"
    </FilesMatch>
    # No cache for HTML, PHP, API responses
    <FilesMatch "\.(html|php)$">
        Header set X-LiteSpeed-Cache-Control "no-store"
    </FilesMatch>
</IfModule>

# ── Cache-Control (standard CDN/browser) ─────────────────────────────────────
<IfModule mod_expires.c>
    ExpiresActive On
    # Hashed assets — 1 year immutable
    <FilesMatch "-[a-f0-9]{8,}\.(js|css|woff2?|png|jpg|jpeg|gif|webp|avif|svg|ico)$">
        ExpiresDefault "access plus 1 year"
        Header append Cache-Control "public, immutable"
    </FilesMatch>
    # HTML and PHP — no cache
    <FilesMatch "\.(html|php)$">
        ExpiresDefault "access plus 0 seconds"
        Header set Cache-Control "no-store, no-cache, must-revalidate"
    </FilesMatch>
</IfModule>

# ── Compression ───────────────────────────────────────────────────────────────
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/css application/javascript application/json application/xml image/svg+xml
</IfModule>
<IfModule mod_brotli.c>
    AddOutputFilterByType BROTLI_COMPRESS text/html text/plain text/css application/javascript application/json application/xml image/svg+xml
</IfModule>

# ── SPA Fallback (only if --spa flag) ─────────────────────────────────────────
# Uncomment if this is a single-page app (React, Vue, etc.)
# RewriteCond %{REQUEST_FILENAME} !-f
# RewriteCond %{REQUEST_FILENAME} !-d
# RewriteRule ^ /index.html [L]

# ── PHP Settings ──────────────────────────────────────────────────────────────
<IfModule mod_php.c>
    php_flag  display_errors       Off
    php_flag  log_errors           On
    php_value error_log            ../logs/php_errors.log
    php_value upload_max_filesize  10M
    php_value post_max_size        12M
    php_value max_execution_time   30
    # ⚠ VERIFY IN hPanel: memory_limit value for your plan
    php_value memory_limit         256M
</IfModule>

# ── Remove server fingerprinting ─────────────────────────────────────────────
ServerSignature Off
```

### 12. Write `deploy.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
SITE_NAME="${SITE_NAME:-mysite}"
SSH_USER="${SSH_USER:-u123456}"         # hPanel SSH username
SSH_HOST="${SSH_HOST:-ssh.hostinger.com}"
SSH_PORT="${SSH_PORT:-65002}"           # Hostinger default SSH port
REMOTE_BASE="~/domains/${SITE_NAME}"
REMOTE_PUBLIC="${REMOTE_BASE}/public_html"
REMOTE_APP="${REMOTE_BASE}/app"
REMOTE_VENDOR="${REMOTE_BASE}/vendor"
CLEAR_LSCACHE="${CLEAR_LSCACHE:-false}" # Set to true to purge LSCache after deploy

# ── Local build ───────────────────────────────────────────────────────────────
echo "→ Installing Node deps..."
npm ci --prefer-offline

echo "→ Running Vite build..."
npm run build

echo "→ Installing Composer deps (no-dev, optimized)..."
composer install \
  --no-dev \
  --optimize-autoloader \
  --classmap-authoritative \
  --no-interaction \
  --no-progress

echo "✓ Build complete"

# ── Verify build artifacts ────────────────────────────────────────────────────
if [ ! -f "public_html/index.php" ] && [ ! -f "public_html/index.html" ]; then
  echo "✗ ERROR: public_html/index.php or index.html not found. Build may have failed."
  exit 1
fi

# ── Exclude list (keep inodes low, never send secrets) ────────────────────────
EXCLUDES=(
  "node_modules/"
  ".git/"
  "src/"
  "config/.env"        # NEVER upload .env — set on server manually
  "tests/"
  "*.map"
  "*.sh"
  "*.md"
  "*.lock"
  ".gitignore"
  ".env*"
  "vite.config.*"
  "tsconfig*"
  "package*.json"
  "composer.json"
  "composer.lock"
)

RSYNC_EXCLUDES=()
for ex in "${EXCLUDES[@]}"; do
  RSYNC_EXCLUDES+=("--exclude=${ex}")
done

SSH_OPTS="-p ${SSH_PORT} -o StrictHostKeyChecking=accept-new"

echo "→ Syncing public_html/ to server..."
rsync -az --delete \
  "${RSYNC_EXCLUDES[@]}" \
  -e "ssh ${SSH_OPTS}" \
  public_html/ \
  "${SSH_USER}@${SSH_HOST}:${REMOTE_PUBLIC}/"

echo "→ Syncing app/ to server..."
rsync -az --delete \
  "${RSYNC_EXCLUDES[@]}" \
  -e "ssh ${SSH_OPTS}" \
  app/ \
  "${SSH_USER}@${SSH_HOST}:${REMOTE_APP}/"

echo "→ Syncing vendor/ to server..."
rsync -az --delete \
  "${RSYNC_EXCLUDES[@]}" \
  -e "ssh ${SSH_OPTS}" \
  vendor/ \
  "${SSH_USER}@${SSH_HOST}:${REMOTE_VENDOR}/"

# ── Optional: clear LSCache ───────────────────────────────────────────────────
if [ "${CLEAR_LSCACHE}" = "true" ]; then
  echo "→ Clearing LiteSpeed cache..."
  ssh -p "${SSH_PORT}" "${SSH_USER}@${SSH_HOST}" \
    "touch ${REMOTE_BASE}/public_html/.lscache_purge_all 2>/dev/null || true"
fi

echo ""
echo "✓ Deploy complete: https://${SITE_NAME}"
echo ""
echo "Post-deploy checks:"
echo "  curl -I https://${SITE_NAME}/"
echo "  curl -o /dev/null https://${SITE_NAME}/config/.env  # expect 403/404"
```

### 13. Write `.gitignore`

```
node_modules/
dist/
public_html/assets/
vendor/
config/.env
logs/
*.map
.DS_Store
```

---

## Deploy Mode (existing project)

When the project already exists and the user says "deploy" or runs against an existing scaffold:

1. **Run pre-deploy checklist** (section below). Stop if any item fails.
2. Run the build:
   ```bash
   npm ci && npm run build && composer install --no-dev --optimize-autoloader --classmap-authoritative
   ```
3. Verify build output exists in `public_html/assets/` with hashed filenames.
4. Run `bash deploy.sh` (or print the exact command with env vars filled in).
5. Run post-deploy checklist.

**Retry policy:** If deploy.sh fails, diagnose the cause first. Do not re-run immediately. Fix the cause, then run once. If you must retry automatically, back off: wait 30s, then 60s, then 120s. Never loop.

---

## FTP / hPanel Git Fallback (no SSH access)

Document this clearly when the user cannot use SSH:

### Option A: hPanel Git Deployment
1. In hPanel → Git → connect the repo.
2. Set deploy branch (e.g., `main`).
3. **Set the deploy path to `public_html/` only** — never deploy the whole repo root.
4. Add a `.cpanel.yml` or hPanel deploy hook to run `composer install --no-dev` after pull.
5. Exclude `node_modules/`, `src/`, `config/.env`, `tests/` in `.gitignore` and confirm hPanel respects them.
6. **Risk:** hPanel Git pulls the whole branch — it is harder to exclude files reliably. Prefer SSH+rsync.

### Option B: FTP (FileZilla / Cyberduck)
1. Build locally first: `npm run build && composer install --no-dev --optimize-autoloader`.
2. Upload `public_html/` contents → remote `public_html/`.
3. Upload `app/` → remote `app/`.
4. Upload `vendor/` → remote `vendor/`.
5. **Never upload:** `src/`, `node_modules/`, `config/.env`, `tests/`, `*.sh`, `*.map`.
6. FTP has no atomic deploy — partial uploads can cause errors. Deploy during low-traffic windows.

---

## Exact File List Sent to Server

Print this table so the user knows exactly what lands on the server:

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

## Pre-Deploy Checklist

Run through each item. Stop and fix before deploying if anything fails.

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
[ ] Inode count below plan limit (⚠ VERIFY IN hPanel → Resource Usage)
[ ] No WebSocket / always-on process required (if yes → STOP, see hard stops above)
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

After running commands, check hPanel → Resource Usage — CPU and RAM should not spike after deploy. If they do, LSCache is not warming correctly.

---

## Output Summary

When the skill completes, print:

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
