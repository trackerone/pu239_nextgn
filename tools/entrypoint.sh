#!/usr/bin/env bash
set -euo pipefail

ROOT="$(/bin/sh /app/tools/detect-root.sh)"
echo "[entrypoint] Using root: $ROOT"

cd "$ROOT"

# Laravel? (artisan present)
if [ -f artisan ]; then
  echo "[entrypoint] Laravel detected."

  # Ensure writable dirs
  mkdir -p storage bootstrap/cache
  chmod -R 775 storage bootstrap/cache || true

  # Ensure APP_KEY exists
  if ! grep -q '^APP_KEY=' .env 2>/dev/null || grep -q '^APP_KEY=\s*$' .env 2>/dev/null; then
    php -r "file_exists('.env') || copy('.env.example', '.env');"
    php artisan key:generate --force || true
  fi

  # Cache things but don't fail hard
  php artisan config:cache || true
  php artisan route:cache || true
  php artisan view:cache || true

  PORT="${PORT:-8000}"
  echo "[entrypoint] Starting server on 0.0.0.0:${PORT}"
  exec php artisan serve --host=0.0.0.0 --port="${PORT}"
fi

# Fallback: just run PHP's built-in server for public/index.php if it exists
if [ -f public/index.php ]; then
  PORT="${PORT:-8000}"
  echo "[entrypoint] No artisan found, serving public/index.php on 0.0.0.0:${PORT}"
  exec php -S 0.0.0.0:"${PORT}" -t public
fi

echo "[entrypoint] No Laravel app detected and no public/index.php found."
exit 1
