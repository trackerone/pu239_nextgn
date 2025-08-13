FROM php:8.2-cli
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y unzip sqlite3
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php && mv composer.phar /usr/local/bin/composer
RUN composer install
CMD ["php", "artisan", "serve", "--host=0.0.0.0"]