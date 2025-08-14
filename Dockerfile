# Web-only friendly Dockerfile for Laravel 11 on Render
# Builds Composer deps inside the container (no local tooling needed)
FROM php:8.2-cli

# System packages & PHP extensions
RUN apt-get update     && apt-get install -y --no-install-recommends git unzip libzip-dev     && docker-php-ext-install zip pdo_mysql     && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"     && php composer-setup.php --install-dir=/usr/local/bin --filename=composer     && rm composer-setup.php

WORKDIR /app

# Bring in project files
COPY . .

# Helper tools
COPY tools/detect-root.sh /app/tools/detect-root.sh
COPY tools/ensure-skeleton.php /app/tools/ensure-skeleton.php
COPY tools/entrypoint.sh /app/tools/entrypoint.sh
RUN chmod +x /app/tools/*.sh

# Resolve composer deps in detected root.
# If composer.lock exists and is non-empty => install
# else => update (to generate a proper lock file)
RUN set -eux;     ROOT=$(/bin/sh /app/tools/detect-root.sh);     echo "[build] Detected root: $ROOT";     cd "$ROOT";     if [ -f composer.json ]; then       if [ -s composer.lock ]; then         echo "[build] composer.lock found -> composer install";         composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader;       else         echo "[build] composer.lock missing or empty -> composer update";         composer update  --no-dev --prefer-dist --no-interaction --optimize-autoloader;       fi;     else       echo "[build] No composer.json found in $ROOT";     fi;     true

EXPOSE 8000

ENV PORT=8000
CMD ["/bin/sh", "/app/tools/entrypoint.sh"]
