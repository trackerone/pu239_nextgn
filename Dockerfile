# Dockerfile
FROM php:8.3-cli

# System deps
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libicu-dev libonig-dev libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions som Laravel forventer
RUN docker-php-ext-install \
    zip intl mbstring bcmath pdo pdo_mysql pdo_sqlite opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . /app

# Sørg for at overlay deployes ind i app-strukturen (din kode bor her)
RUN [ -d /app/overlay ] && cp -R /app/overlay/* /app/ || true

# Installér afhængigheder i build (fail fast!)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Forbered writeable dirs (men ingen artisan-kommandoer i build!)
RUN mkdir -p storage/framework/{cache,views,sessions} bootstrap/cache \
 && chmod -R 0777 storage bootstrap/cache

# (Valgfrit) PHP-ini
# COPY tools/php.ini /usr/local/etc/php/conf.d/zzz-custom.ini

# Render lytter på $PORT; vi sætter en default
ENV PORT=10000
EXPOSE 10000

# Runtime sker i entrypoint
CMD ["sh","/app/tools/entrypoint.sh"]
