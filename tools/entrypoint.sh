#!/usr/bin/env sh
set -e

ROOT=$(/bin/sh /app/tools/detect-root.sh)
echo "[entrypoint] Using root: $ROOT"
cd "$ROOT"

if [ ! -d storage ]; then mkdir -p storage; fi
if [ ! -d bootstrap/cache ]; then mkdir -p bootstrap/cache; fi
chmod -R ug+rwX storage bootstrap/cache || true

if [ -f artisan ]; then
  php artisan config:cache || true
  php artisan route:cache || true
  php artisan view:cache || true
fi

PORT=${PORT:-8000}
echo "[entrypoint] Laravel detected. Starting server on 0.0.0.0:${PORT} ..."
exec php artisan serve --host=0.0.0.0 --port="${PORT}"
