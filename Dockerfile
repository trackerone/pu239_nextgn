# Dockerfile
FROM php:8.3-cli

# System deps
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libicu-dev libonig-dev libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions som Laravel typisk kræver/forventer
RUN docker-php-ext-install \
    zip intl mbstring bcmath pdo pdo_mysql pdo_sqlite opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . /app

# (Valgfrit men godt) egen php.ini
COPY tools/php.ini /usr/local/etc/php/conf.d/zzz-custom.ini

# Sørg for at overlay kommer med (se punkt 2)
# cp -R virker i busybox/sh – rsync er ikke garanteret i base-billedet
RUN [ -d /app/overlay ] && cp -R /app/overlay/* /app/ || true

# Installer afhængigheder – FEJL hvis det ikke lykkes
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Skab .env og app key under build (så artisan kan køre i entrypoint uden at fejle)
RUN php -r "file_exists('.env') || copy('.env.example', '.env');" \
 && php artisan key:generate --force \
 && mkdir -p storage bootstrap/cache \
 && chmod -R 0777 storage bootstrap/cache

EXPOSE 10000
CMD ["sh","/app/tools/entrypoint.sh"]
