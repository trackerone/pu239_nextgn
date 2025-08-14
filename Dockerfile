FROM php:8.2-cli

# System deps + PHP extensions
RUN apt-get update  && apt-get install -y --no-install-recommends git unzip libzip-dev  && docker-php-ext-install zip pdo_mysql  && rm -rf /var/lib/apt/lists/*

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer  && rm composer-setup.php

WORKDIR /app
COPY . .
COPY tools/detect-root.sh /app/tools/detect-root.sh
COPY tools/ensure-skeleton.php /app/tools/ensure-skeleton.php
COPY tools/entrypoint.sh /app/tools/entrypoint.sh
RUN chmod +x /app/tools/*.sh

# Build-time composer (generate/install lock)
RUN set -eux;     ROOT=$(/bin/sh /app/tools/detect-root.sh);     echo "[build] Detected root: $ROOT";     cd "$ROOT";     if [ -f composer.json ]; then       if [ -s composer.lock ]; then         echo "[build] composer.lock found -> install";         composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader;       else         echo "[build] composer.lock missing -> update";         composer update  --no-dev --prefer-dist --no-interaction --optimize-autoloader;       fi;     else       echo "[build] No composer.json found";     fi;     true

ENV PORT=8000
EXPOSE 8000
CMD ["/app/tools/entrypoint.sh"]
