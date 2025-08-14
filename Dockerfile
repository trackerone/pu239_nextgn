FROM php:8.2-cli

# OS deps + PHP extensions
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

# === KRITISK TRIN: hvis der ikke er et Laravel-skelet, så hent ét ===
# (Det fjerner dependency-konflikten.)
RUN set -eux; \
    if [ ! -f bootstrap/app.php ]; then \
      composer create-project laravel/laravel:^11.0 /tmp/skeleton --no-dev --prefer-dist --no-interaction; \
      cp -a /tmp/skeleton/. /app/; \
    fi; \
    composer require laravel/tinker:^2.8 fruitcake/laravel-cors:^3.0 --no-dev --prefer-dist --no-interaction; \
    composer dump-autoload -o

# Sørg for cache-mappe (hvis ikke oprettet af skeleton)
RUN mkdir -p bootstrap/cache && touch bootstrap/cache/.gitkeep

ENV PORT=8000
EXPOSE 8000

# Simpelt runtime-setup + server
CMD bash -lc '\
  if [ ! -f .env ] && [ -f .env.example ]; then cp .env.example .env; fi; \
  php artisan key:generate --force || true; \
  php artisan config:clear || true; php artisan route:clear || true; php artisan view:clear || true; \
  php artisan config:cache || true; php artisan route:cache || true; php artisan view:cache || true; \
  php -S 0.0.0.0:${PORT} -t public'
