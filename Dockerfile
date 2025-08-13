FROM php:8.2-cli

# Install system deps needed by Composer (git, unzip) and PHP zip extension
RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip libzip-dev \
    && docker-php-ext-install zip pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_DISABLE_XDEBUG_WARN=1

WORKDIR /app

# Copy composer.json + fixer and sanitize before resolving deps
COPY composer.json ./
COPY tools/fix-composer.php tools/fix-composer.php
RUN php tools/fix-composer.php

# Resolve deps and write composer.lock inside the image (no local machine needed)
RUN composer update --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Bring in the rest of the app
COPY . .

# Cache config after vendor exists (don't fail build if env not set yet)
RUN php artisan config:cache || true

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
