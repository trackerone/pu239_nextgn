FROM php:8.2-cli
COPY . /app
WORKDIR /app
RUN chmod +x artisan
CMD php artisan serve
