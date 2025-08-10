# ---------- Build vendors (Composer) ----------
FROM composer:2 AS composer_stage
WORKDIR /app
# Init et helt nyt Laravel-projekt direkte i container-build
RUN composer create-project --no-dev --prefer-dist laravel/laravel /app
# Optimer autoload
RUN composer dump-autoload --no-dev --optimize

# ---------- Build assets (Vite) ----------
FROM node:20-alpine AS node_stage
WORKDIR /app
COPY --from=composer_stage /app /app
# Installer frontend afhængigheder hvis package.json findes
RUN if [ -f package.json ]; then npm ci && npm run build; else echo "no assets"; fi || true

# ---------- Runtime: PHP-FPM + Caddy ----------
FROM php:8.3-fpm-alpine
WORKDIR /var/www/html

# PHP extensions
RUN apk add --no-cache libpq-dev libzip-dev zip git curl bash \
 && docker-php-ext-install pdo pdo_pgsql opcache

# Kopiér app fra build-stages
COPY --from=composer_stage /app /var/www/html
# --- BEGIN overlay ---
# Copy repo overrides (controllers, routes, views, etc.)
# Everything you place under /overlay in the repo will overwrite the base Laravel app.
COPY overlay/ /var/www/html/
# --- END overlay ---

COPY --from=node_stage /app/public/build /var/www/html/public/build 2>/dev/null || true

# Caddy som webserver (simpelt og hurtigt)
RUN apk add --no-cache caddy

# Health endpoint (simpel statisk fil)
RUN mkdir -p /var/www/html/public && echo "ok" > /var/www/html/public/health

# Laravel permissions
RUN chown -R www-data:www-data /var/www/html && \
    mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Copy Caddyfile og startscript
COPY deploy/Caddyfile /etc/caddy/Caddyfile
COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV APP_ENV=production
EXPOSE 8080

CMD ["/start.sh"]
