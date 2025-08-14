FROM php:8.2-cli

RUN apt-get update \
 && apt-get install -y --no-install-recommends git unzip libzip-dev \
 && docker-php-ext-install zip pdo_mysql \
 && rm -rf /var/lib/apt/lists/*

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && rm composer-setup.php

WORKDIR /app
COPY . .
RUN chmod +x /app/tools/entrypoint.sh

EXPOSE 10000
ENTRYPOINT ["/app/tools/entrypoint.sh"]
