FROM php:8.2-cli

RUN apt-get update && apt-get install -y unzip git curl libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY . /app
WORKDIR /app

RUN composer install --optimize-autoloader --no-dev

RUN php artisan config:cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
