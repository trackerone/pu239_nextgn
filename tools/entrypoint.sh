#!/bin/sh
set -e
ROOT=$(/bin/sh /app/tools/detect-root.sh)
cd "$ROOT"
echo "[entrypoint] Using root: $ROOT"

# Ensure skeleton + writable dirs
php /app/tools/ensure-skeleton.php

# Try to optimize/caches if artisan exists (but don't fail hard)
if [ -f "artisan" ]; then
  mkdir -p bootstrap/cache storage/framework/{cache,sessions,views}
  chmod -R 777 bootstrap/cache storage || true
  php artisan config:cache || true
  php artisan route:cache || true
  php artisan view:cache || true
fi

if [ -f "artisan" ] && [ -f "bootstrap/app.php" ]; then
  echo "[entrypoint] Laravel detected. Starting server..."
  exec php artisan serve --host=0.0.0.0 --port=8000
else
  echo "[entrypoint] Fallback: serving public/ (if present)"
  ls -la public || true
  exec php -S 0.0.0.0:8000 -t public 2>/dev/null || sleep 3600
fi
