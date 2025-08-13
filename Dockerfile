FROM php:8.2-cli

# Install Composer (global)
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php

WORKDIR /app

# Copy only composer files first for better layer caching
COPY composer.json composer.lock ./

# Install dependencies from lock (no-dev for production images)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Now copy the rest of the application code
COPY . .

# Cache config (requires vendor to exist already)
RUN php artisan config:cache

# Default command (dev-ish). Replace with your real entrypoint in production.
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
