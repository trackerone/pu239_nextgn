FROM php:8.2-cli

# Systempakker + PHP extensions
RUN apt-get update \
 && apt-get install -y --no-install-recommends git unzip libzip-dev \
 && docker-php-ext-install zip pdo_mysql \
 && rm -rf /var/lib/apt/lists/*

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && rm composer-setup.php

WORKDIR /app
COPY . .

# Vigtigt: ingen “plugins/scripts” under build – de kan forsøge at køre Artisan før skeleton findes.
# Slet gammel lock i repo - vi forventer at du har fjernet den i GitHub allerede.
RUN set -eux; \
    if [ -f composer.lock ]; then rm -f composer.lock; fi; \
    composer update --no-dev --prefer-dist --no-interaction --optimize-autoloader --no-plugins --no-scripts

# Sørg for skeleton og cache-mappe
RUN mkdir -p bootstrap/cache \
 && touch bootstrap/cache/.gitkeep

# Nu må Artisan commands gerne køre (skeleton er på plads)
# .env.example findes -> post-root install vil kopiere til .env ved runtime/entrypoint,
# men vi kan lave config cache osv. først når app kan loades.
# Vi undlader config:cache i build – gør det i entrypoint når .env findes.

ENV PORT=8000
EXPOSE 8000

# Simpelt entrypoint der sikrer .env & key & caches før server start
CMD bash -lc '\
  if [ ! -f .env ]; then cp .env.example .env || true; fi; \
  if ! grep -q "APP_KEY=base64:" .env; then php artisan key:generate --force || true; fi; \
  php artisan config:clear || true; php artisan route:clear || true; php artisan view:clear || true; \
  php artisan config:cache || true; php artisan route:cache || true; php artisan view:cache || true; \
  php -S 0.0.0.0:${PORT} -t public'
