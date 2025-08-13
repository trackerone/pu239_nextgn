FROM php:8.2-cli

# Install Composer (global)
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"         && php composer-setup.php --install-dir=/usr/local/bin --filename=composer         && rm composer-setup.php

WORKDIR /app

# Copy composer.json early + fixer so we can sanitize dependencies BEFORE resolve
COPY composer.json ./
COPY tools/fix-composer.php tools/fix-composer.php

# Run fixer: removes direct illuminate/*, ensures laravel/framework ^11
# Also removes any previous invalid conflict entries (like "illuminate/*").
RUN php tools/fix-composer.php

# Resolve deps and write composer.lock inside the image (no local machine needed)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer update --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Bring in the rest of the app
COPY . .

# Cache config after vendor exists
RUN php artisan config:cache

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
