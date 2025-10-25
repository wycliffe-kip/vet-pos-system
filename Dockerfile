FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libpq-dev \
    git \
    unzip \
    zip \
    curl \
    && docker-php-ext-install pdo pdo_pgsql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN a2enmod rewrite
WORKDIR /var/www/html

# Copy entire application
COPY . .

# Install without running any scripts
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress --no-scripts

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

EXPOSE 80
CMD ["apache2-foreground"]