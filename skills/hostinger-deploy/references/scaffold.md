# Hostinger Deploy — Scaffold Mode

> Loaded by SKILL.md for `scaffold` / new project. Read SKILL.md (Plan Specs, Hard Stops, Mode Detection) first.

Produce complete, ready-to-use scaffold. Write every file with real content, no placeholders.

### 1. Determine Site Name

Use argument (e.g., `hostinger-deploy mysite`) or ask. Name becomes `SITE_NAME` in deploy.sh.

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
├── db/
│   └── schema.sql              # CREATE TABLEs + essential baseline INSERTs (no seeders)
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

If `--laravel`: this scaffold (Vite + plain-PHP/Slim layout) does **not** apply. Laravel has its own structure and git-pull deploy — stop here and follow `references/laravel.md`. Note once: Laravel adds ~30 MB / heavy inodes; for simple CRUD, plain PHP + PDO or Slim is lighter.

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

### 7b. Write `db/schema.sql`

Schema, not seeders (see SKILL.md "Database Setup"). Plain DDL imported once via phpMyAdmin → Import or `mysql -u <user> -p <db> < db/schema.sql`. Commit this file; it is the source of truth for the DB shape. Only essential reference rows in the `INSERT` block — never demo/sample/faker data.

```sql
-- db/schema.sql — MySQL/MariaDB. Import once per environment.
SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS users (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email       VARCHAR(255)    NOT NULL,
  created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Essential reference data only (roles, settings). NOT demo data.
-- INSERT INTO settings (k, v) VALUES ('site_name', 'My Site');
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

Most critical file. Write in full:

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

