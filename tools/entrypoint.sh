#!/bin/sh
set -eu
cd /app

mkdir -p /tmp && chmod 1777 /tmp
export TMPDIR=/tmp

[ -f .env ] || [ ! -f .env.example ] || cp .env.example .env

mkdir -p storage/framework/cache \
         storage/framework/views \
         storage/framework/sessions \
         bootstrap/cache
chmod -R 0777 storage bootstrap || true

php artisan key:generate --force || true
php artisan config:cache  || true
php artisan route:cache   || true
php artisan view:cache    || true

: "${PORT:=10000}"
exec php -S 0.0.0.0:${PORT} -t public
