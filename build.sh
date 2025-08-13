#!/bin/bash

set -e

# Installer afhængigheder
composer install --no-dev --optimize-autoloader

# Lav en fallback .env, hvis den ikke allerede findes
if [ ! -f .env ]; then
  cp .env.example .env
fi

# Generér nøgle (kun første gang)
php artisan key:generate || true

# Kør migrationer
php artisan migrate --force || true

# Byg frontend (hvis du bruger Vite/NPM)
if [ -f vite.config.js ]; then
  npm install && npm run build
fi
