#!/bin/sh
set -e

ROOT=$(/bin/sh /app/tools/detect-root.sh)
echo "[entrypoint] Using root: $ROOT"
cd "$ROOT"

# Ensure skeleton files & dirs
php /app/tools/ensure-skeleton.php

# Ensure writable dirs
mkdir -p storage bootstrap/cache
chmod -R 777 storage bootstrap/cache || true
echo "[entrypoint] Writable dirs ensured"

# Ensure .env exists
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
  cp .env.example .env
  echo "[entrypoint] .env created from .env.example"
fi

# APP_URL default for Render (if not set)
if ! grep -q "^APP_URL=" .env 2>/dev/null; then
  echo "APP_URL=${RENDER_EXTERNAL_URL:-http://localhost}" >> .env
fi

# Generate key if missing
if ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
  php artisan key:generate --force || true
  echo "[entrypoint] APP_KEY generated (if it was missing)"
fi

# Optional storage link (won't fail deploy if it already exists)
php artisan storage:link || true

# Cache warmup (won't fail the container)
php artisan config:cache   || true
php artisan route:cache    || true
php artisan view:cache     || true

echo "[entrypoint] Laravel detected. Starting server..."
exec php artisan serve --host=0.0.0.0 --port="${PORT:-8000}"
