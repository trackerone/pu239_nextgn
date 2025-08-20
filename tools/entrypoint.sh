#!/bin/sh
set -eu

cd /app

# Garanter en skrivbar /tmp (tempnam m.m.)
mkdir -p /tmp && chmod 1777 /tmp
export TMPDIR=/tmp

# Lille helper: sikrer at en sti ender som mappe
ensure_dir() {
  p="$1"
  if [ -e "$p" ] && [ ! -d "$p" ]; then
    rm -f "$p"
  fi
  mkdir -p "$p"
}

# .env første gang
if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
fi

# Sørg for korrekte writeable dirs, også hvis noget er blevet til en fil
ensure_dir storage
ensure_dir storage/framework
ensure_dir storage/framework/cache
ensure_dir storage/framework/views
ensure_dir storage/framework/sessions
ensure_dir bootstrap
ensure_dir bootstrap/cache
chmod -R 0777 storage bootstrap || true

# Generér app key og varm caches (må gerne være best-effort)
php artisan key:generate --force || true
php artisan config:cache  || true
php artisan route:cache   || true
php artisan view:cache    || true

# Start server på Render's port
: "${PORT:=10000}"
exec php -S 0.0.0.0:${PORT} -t public
