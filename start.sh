#!/usr/bin/env bash
set -e

APP_DIR="/var/www/html"
cd "$APP_DIR"

echo "[startup] Ensure required dirs…"
mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache

echo "[startup] Fixing permissions…"
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R 775 storage bootstrap/cache || true
find storage -type d -exec chmod 775 {} \; || true
find storage -type f -exec chmod 664 {} \; || true
find bootstrap/cache -type d -exec chmod 775 {} \; || true
find bootstrap/cache -type f -exec chmod 664 {} \; || true

# Wait for Postgres if configured
if [ -n "${DB_HOST}" ] && [ "${DB_CONNECTION}" = "pgsql" ]; then
  echo "[startup] Waiting for Postgres at ${DB_HOST}:${DB_PORT:-5432}…"
  for i in {1..60}; do
    if php -r "pg_connect('host=${DB_HOST} port=${DB_PORT:-5432} dbname=${DB_DATABASE} user=${DB_USERNAME} password=${DB_PASSWORD}') ?: exit(1);"; then
      echo "[startup] Postgres is ready."
      break
    fi
    sleep 1
  done
fi

echo "[startup] Clear caches…"
php artisan config:clear || true
php artisan route:clear  || true
php artisan view:clear   || true

echo "[startup] Generate app key…"
php artisan key:generate --force || true

echo "[startup] Run migrations…"
php artisan migrate --force || true

echo "[startup] Rebuild caches…"
php artisan config:cache || true
php artisan route:cache  || true

echo "ok" > public/health || true
chown www-data:www-data public/health || true

echo "[startup] Starting PHP-FPM and Caddy…"
php-fpm -D
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
