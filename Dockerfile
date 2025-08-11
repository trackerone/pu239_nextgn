# ===========================================
# 1) Composer stage: create Laravel + install Breeze
# ===========================================
FROM composer:2 AS composer_stage
WORKDIR /app
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer create-project --no-dev --prefer-dist laravel/laravel /app
WORKDIR /app
RUN composer require laravel/breeze:^2.0 --dev
RUN php artisan key:generate --force
RUN php artisan breeze:install blade --no-interaction

# ===========================================
# 2) Node stage: build Breeze assets
# ===========================================
FROM node:20-alpine AS node_stage
WORKDIR /app
COPY --from=composer_stage /app /app
RUN npm ci && npm run build
# Ensure build path exists even if nothing was produced (defensive)
RUN mkdir -p /app/public/build

# ===========================================
# 3) Runtime: PHP-FPM (8.3) + Caddy on Alpine
# ===========================================
FROM php:8.3-fpm-alpine
WORKDIR /var/www/html

# System deps + Caddy + PHP extensions
RUN apk add --no-cache         git curl bash zip unzip caddy         libpq-dev libzip-dev icu-dev oniguruma-dev

RUN docker-php-ext-configure intl      && docker-php-ext-install -j$(nproc) pdo pdo_pgsql mbstring intl zip opcache

# Copy application from build stages
COPY --from=composer_stage /app /var/www/html
COPY --from=node_stage     /app/public/build /var/www/html/public/build

# Overlay from repo (routes, tracker, etc.)
COPY overlay/ /var/www/html/

# Web server config + startup
COPY deploy/Caddyfile /etc/caddy/Caddyfile
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Permissions for Laravel writable dirs
RUN chown -R www-data:www-data /var/www/html      && chmod -R ug+rwX /var/www/html/storage /var/www/html/bootstrap/cache

# Handle possible CRLF in start.sh gracefully
RUN apk add --no-cache dos2unix && dos2unix /start.sh || true

# Health file
RUN mkdir -p /var/www/html/public && echo "ok" > /var/www/html/public/health

ENV APP_ENV=production
EXPOSE 8080

CMD ["/start.sh"]
