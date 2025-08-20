#!/bin/sh
set -eu

cd /app

# Sørg for, at /tmp findes og er skrivbar (tempnam bruger den)
mkdir -p /tmp && chmod 1777 /tmp
export TMPDIR=/tmp

# .env første gang
if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
fi

# Nødvendige writeable dirs (igen, hvis containeren er “kold”)
mkdir -p storage/framework/cache storage/framework/views storage/framework/sessions bootstrap/cache
chmod -R 0777 storage bootstrap/cache

# Generér app key, men lad ikke en notice dræbe boot
# (Laravel løfter notices til exceptions; derfor || true)
php artisan key:generate --force || true

# Cache ting – må gerne være best-effort i Free-miljø
php artisan config:cache  || true
php artisan route:cache   || true
php artisan view:cache    || true

# Start server på Render’s port
: "${PORT:=10000}"
exec php -S 0.0.0.0:${PORT} -t public
