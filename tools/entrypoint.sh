#!/usr/bin/env bash
set -euo pipefail

ROOT="/app"
cd "$ROOT"

echo "[entrypoint] Using root: $ROOT"

# 1) Sikr Laravel skeleton findes
if [ ! -f "$ROOT/bootstrap/app.php" ]; then
  echo "[entrypoint] No Laravel skeleton detected -> creating project"
  composer create-project laravel/laravel:^11.0 "$ROOT" --prefer-dist --no-interaction
fi

# 2) Sikr .env findes
if [ ! -f "$ROOT/.env" ]; then
  if [ -f "$ROOT/.env.example" ]; then
    php -r "copy('.env.example', '.env');"
  else
    echo "[entrypoint] WARNING: .env.example not found, creating minimal .env"
    cat > "$ROOT/.env" <<'EOF'
APP_NAME=Laravel
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://localhost
LOG_CHANNEL=stack
LOG_LEVEL=info

# DB - udfyld via Render ENV
DB_CONNECTION=mysql
DB_HOST=
DB_PORT=3306
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=

# Server
APP_PORT=${PORT:-10000}
EOF
  fi
fi

# 3) Installer deps (hurtig, idempotent)
if [ -f "$ROOT/composer.json" ]; then
  echo "[entrypoint] Running composer install (no-dev)"
  composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader || true
fi

# 4) APP_KEY
if [ -z "${APP_KEY:-}" ] || [ "$APP_KEY" = "" ]; then
  echo "[entrypoint] APP_KEY missing -> generating"
  php artisan key:generate --force || true
fi

# 5) Symlink storage (idempotent)
php artisan storage:link || true

# 6) (Valgfrit) Migrationer i prod – kun hvis DB-ENV sat
if [ -n "${DB_HOST:-}" ] && [ -n "${DB_DATABASE:-}" ] && [ -n "${DB_USERNAME:-}" ]; then
  echo "[entrypoint] Running migrations"
  php artisan migrate --force || true
fi

# 7) Start server
PORT="${PORT:-10000}"
echo "[entrypoint] Starting server on 0.0.0.0:${PORT}"
exec php artisan serve --host=0.0.0.0 --port="${PORT}"
