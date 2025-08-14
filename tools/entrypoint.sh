#!/usr/bin/env bash
set -euo pipefail

export APP_ROOT="${APP_ROOT:-/app}"
cd "$APP_ROOT"

php /app/tools/ensure-skeleton.php

# Composer autoload (in case of fresh container)
if [ -f composer.json ] && [ ! -d vendor ]; then
  composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader || true
fi

# Laravel optimize (tolerate missing artisan in first run)
if [ -f artisan ]; then
  php artisan config:cache || true
  php artisan route:cache || true
  php artisan view:cache || true
fi

PORT="${PORT:-8000}"
echo "[entrypoint] Starting server on 0.0.0.0:${PORT}"
exec php -S 0.0.0.0:"$PORT" -t public
