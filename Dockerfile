FROM php:8.3-cli

# System deps
RUN apt-get update && apt-get install -y git unzip libzip-dev && docker-php-ext-install zip && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . /app

# Fjern evt. CRLF fra entrypoint-scriptet
RUN sed -i 's/\r$//' /app/tools/entrypoint.sh

# Hurtig sanity under build (ingen netværk ved runtime kræves)
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader || true

EXPOSE 10000
CMD ["/app/tools/entrypoint.sh"]
