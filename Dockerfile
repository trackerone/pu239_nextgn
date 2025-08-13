FROM php:8.2-cli

# System deps + PHP extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip libzip-dev \
    && docker-php-ext-install zip pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_DISABLE_XDEBUG_WARN=1

WORKDIR /app

# Copy whole repo early (we need to detect root dir)
COPY . .

# Tools
COPY tools/detect-root.sh /app/tools/detect-root.sh
COPY tools/fix-composer.php /app/tools/fix-composer.php

# Detect root (handles subfolders) and fix composer.json there
RUN ROOT=$(/app/tools/detect-root.sh) \
    && echo "[build] Detected root: $ROOT" \
    && cd "$ROOT" \
    && if [ -f composer.json ]; then php /app/tools/fix-composer.php; else echo "[build] No composer.json found in $ROOT"; fi \
    && if [ -f composer.json ]; then composer update --no-dev --prefer-dist --no-interaction --optimize-autoloader; fi \
    && true

# Cache config if artisan exists (don't fail build otherwise)
RUN ROOT=$(/app/tools/detect-root.sh) \
    && cd "$ROOT" \
    && if [ -f artisan ]; then php artisan config:cache || true; fi

EXPOSE 8000
ENTRYPOINT ["/app/tools/entrypoint.sh"]
