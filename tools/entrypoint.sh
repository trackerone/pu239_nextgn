# tools/entrypoint.sh
#!/bin/sh
set -eu

cd /app

# Sikr .env ved første run
if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
fi

# Key skal findes – ellers er miljøet ikke klart
php artisan key:generate --force

# Cache – må gerne fejle i first-boot scenarier, men normalt skal det virke
php artisan config:cache  || true
php artisan route:cache   || true
php artisan view:cache    || true

# (Valgfrit) Kør migrationer hvis DB er sat op; ellers lad være.
# php artisan migrate --force || true

# Start den indbyggede server på Render’s PORT
: "${PORT:=10000}"
php -S 0.0.0.0:${PORT} -t public
