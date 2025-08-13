FROM php:8.3-cli

# Install system dependencies
RUN apt-get update && apt-get install -y unzip git libzip-dev zip libpq-dev libonig-dev libxml2-dev \
 && docker-php-ext-install pdo pdo_pgsql zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy project
COPY . .

# Install PHP deps
RUN composer install --no-dev --optimize-autoloader

# Copy .env.example if .env does not exist
RUN [ -f .env ] || cp .env.example .env

# Clear caches at runtime
CMD ["php", "artisan", "config:clear"] && \
    php artisan migrate --force && \
    php artisan serve --host=0.0.0.0 --port=8000

EXPOSE 8000
