# Start fra en officiel PHP-billede med nødvendige extensions
FROM php:8.2-cli

# Installer systempakker og PHP extensions (som Laravel typisk kræver)
RUN apt-get update && apt-get install -y unzip git curl libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Kopiér filer og sæt arbejdskatalog
COPY . /app
WORKDIR /app

# Installer PHP-afhængigheder
RUN composer install --optimize-autoloader --no-dev

# Kør Laravel build (hvis du bruger Mix eller Vite - ellers fjern linjen nedenfor)
# RUN npm install && npm run build

# Cache Laravel config
RUN php artisan config:cache

# Exponér port 8000
EXPOSE 8000

# Start Laravel dev-server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
