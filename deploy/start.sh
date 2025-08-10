#!/usr/bin/env bash
set -e

# Vent lidt på Postgres ved første boot
if [ -n "${DB_HOST}" ]; then
  echo "Waiting for database ${DB_HOST}:${DB_PORT:-5432}…"
  for i in {1..60}; do
    if php -r "pg_connect('host=${DB_HOST} port=${DB_PORT:-5432} dbname=${DB_DATABASE} user=${DB_USERNAME} password=${DB_PASSWORD}') ?: exit(1);"; then
      break
    fi
    sleep 1
  done
fi

# Laravel bootstrap
cd /var/www/html
php artisan key:generate --force || true
php artisan config:cache || true
php artisan route:cache || true
php artisan migrate --force || true

# Start PHP-FPM + Caddy
php-fpm -D
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
