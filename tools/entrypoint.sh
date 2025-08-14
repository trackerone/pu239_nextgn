#!/usr/bin/env bash
set -euo pipefail

ROOT="/app"
cd "$ROOT"

echo "[entrypoint] Using root: $ROOT"

# Opret Laravel skeleton hvis det mangler (første gang)
if [ ! -f "$ROOT/bootstrap/app.php" ]; then
  echo "[entrypoint] No Laravel skeleton found -> creating"
  composer create-project laravel/laravel:^11.0 /tmp/skeleton --no-interaction --prefer-dist
  cp -a /tmp/skeleton/. "$ROOT"/
fi

# Sikkerhed: hvis nogen har lagt fruitcake i composer.json, så fjern den
if grep -q '"fruitcake/laravel-cors"' composer.json 2>/dev/null; then
  echo "[entrypoint] Removing incompatible fruitcake/laravel-cors"
  composer remove fruitcake/laravel-cors --no-interaction || true
fi

echo "[entrypoint] Running composer install"
composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

# .env + APP_KEY
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
  cp .env.example .env
fi
if ! grep -q "^APP_KEY=" .env 2>/dev/null || grep -q "^APP_KEY=$" .env 2>/dev/null; then
  echo "[entrypoint] APP_KEY missing -> generating"
  php artisan key:generate --force || true
fi

# Caches og symlink
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true

php artisan storage:link || true

# Start server
PORT="${PORT:-10000}"
echo "[entrypoint] Starting server on 0.0.0.0:${PORT}"
php -S 0.0.0.0:"$PORT" -t public
