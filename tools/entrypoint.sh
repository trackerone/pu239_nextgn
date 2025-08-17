#!/bin/sh
set -eu

cd /app

# Lav .env hvis den mangler (failer ikke hvis .env.example ikke findes)
if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env || true
fi

# Laravel nøglen (failer ikke hvis allerede sat)
php artisan key:generate --force || true

# (Valgfrit men nyttigt) cache ting – ignorer fejl hvis miljøet ikke er helt klart endnu
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Start den indbyggede PHP server på Render’s PORT (fallback 10000)
php -S 0.0.0.0:${PORT:-10000} -t public
