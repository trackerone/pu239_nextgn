# ===========================================
# 1) Composer stage: Build a fresh Laravel app
# ===========================================
FROM composer:2 AS composer_stage
WORKDIR /app

# Create clean Laravel skeleton
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer create-project --no-dev --prefer-dist laravel/laravel /app

# ===========================================
# 2) Node stage: (Optional) build Vite assets
# ===========================================
FROM node:20-alpine AS node_stage
WORKDIR /app

# Bring in the app to build assets if package.json exists
COPY --from=composer_stage /app /app

# Build assets if present; never fail build if assets are missing
RUN if [ -f package.json ]; then npm ci && npm run build; else echo "No package.json; skipping asset build"; fi || true
# Ensure path exists so next COPY never fails
RUN mkdir -p /app/public/build

# ===========================================
# 3) Runtime: PHP-FPM + Caddy
# ===========================================
FROM php:8.3-fpm-alpine
WORKDIR /var/www/html

# System deps (incl. Caddy) + PHP extensions for Laravel + Postgres
RUN apk add --no-cache \
    git curl bash zip unzip caddy \
    libpq-dev libzip-dev icu-dev oniguruma-dev

# PHP extensions
RUN docker-php-ext-configure intl \
 && docker-php-ext-install -j$(nproc) pdo pdo_pgsql mbstring intl zip opcache

# Copy app from composer stage
COPY --from=composer_stage /app /var/www/html

# Copy built assets (if any) from node stage
COPY --from=node_stage /app/public/build /var/www/html/public/build

# ---- Overlay: your app overrides (routes, views, etc.) ----
# Everything under overlay/ in the repo will overwrite the base Laravel app
COPY overlay/ /var/www/html/

# Web server config + startup script
COPY deploy/Caddyfile /etc/caddy/Caddyfile
COPY start.sh /start.sh

# Permissions and small niceties
RUN chmod +x /start.sh \
 && addgroup -g 1000 www \
 && adduser -G www -g www -s /bin/sh -D www \
 && chown -R www:www /var/www/html

# Avoid CRLF issues if file was edited on Windows (safe no-op otherwise)
RUN apk add --no-cache dos2unix && dos2unix /start.sh || true

# Simple health path (served by Caddy as static file)
RUN mkdir -p /var/www/html/public && echo "ok" > /var/www/html/public/health

# Environment defaults (Render will inject real values)
ENV APP_ENV=production
EXPOSE 8080

# Run PHP-FPM (daemonized) + Caddy in foreground
CMD ["/start.sh"]
