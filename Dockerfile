# --- Build base (Composer + Node) ---
FROM composer:2 AS composer
FROM node:20 AS node

# --- PHP stage ---
FROM php:8.3-fpm AS php
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libicu-dev libonig-dev libfreetype6-dev \
    libjpeg62-turbo-dev libpng-dev libssl-dev libxml2-dev libpq-dev \
 && docker-php-ext-install pdo pdo_mysql pdo_pgsql zip intl gd \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html
COPY . /var/www/html

# Composer deps
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --prefer-dist --optimize-autoloader

# Node build
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
 && (npm ci --omit=dev --no-fund --no-audit || npm install --no-fund --no-audit) \
 && (npm run build || npm run build --if-present)

# NOTE: Ingen config/route/view cache i build! Det sker ved runtime.

# --- Runtime (Nginx + PHP-FPM) ---
FROM nginx:1.27-alpine
COPY --from=php /usr/local/etc/php/ /usr/local/etc/php/
COPY --from=php /usr/local/bin/php-fpm /usr/local/bin/php-fpm
COPY --from=php /usr/local/sbin/php-fpm* /usr/local/sbin/
COPY --from=php /var/www/html /var/www/html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html
ENV APP_ENV=staging
EXPOSE 80

# Ryd caches ved opstart (nu kendes ENV-variabler fra Render)
CMD ["/bin/sh","-lc","php artisan config:clear && php artisan cache:clear && php artisan route:clear && php artisan view:clear && php-fpm -D && nginx -g 'daemon off;'"]
