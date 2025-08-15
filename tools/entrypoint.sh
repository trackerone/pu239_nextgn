#!/usr/bin/env bash
set -euo pipefail

ROOT="/app"
cd "$ROOT"

# Installer dependencies (prod)
if [ ! -d "vendor" ]; then
  composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader
else
  composer dump-autoload -o
fi

# .env + APP_KEY
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
  cp .env.example .env
fi
php artisan key:generate --force || true

# Cache/links
php artisan storage:link || true
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true

# Kør PHP’s indbyggede server (Render sætter $PORT)
PORT="${PORT:-10000}"
exec php -S 0.0.0.0:"$PORT" -t public
