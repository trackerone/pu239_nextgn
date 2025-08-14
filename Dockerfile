FROM php:8.2-cli

# System deps
RUN apt-get update \
 && apt-get install -y --no-install-recommends git unzip libzip-dev \
 && docker-php-ext-install zip pdo_mysql \
 && rm -rf /var/lib/apt/lists/*

# Composer
RUN php -r "copy('https://getcomposer.org/installer','composer-setup.php');" \
 && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && rm composer-setup.php

WORKDIR /app

# Kopiér repo-indhold (din composer.json mv.)
COPY . .

# Gør scripts eksekverbare
RUN chmod +x /app/tools/*.sh || true

# (Build-safety) Hvis skeleton mangler ved build, så generér det her også
RUN set -eux; \
  if [ ! -f /app/bootstrap/app.php ]; then \
    composer create-project laravel/laravel:^11.0 /tmp/skeleton --prefer-dist --no-interaction; \
    cp -a /tmp/skeleton/. /app/; \
  fi; \
  true

ENV PORT=10000
EXPOSE 10000

ENTRYPOINT ["/app/tools/entrypoint.sh"]
