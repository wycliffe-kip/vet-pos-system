# Use official PHP + Apache image
FROM php:8.2-apache

# Install PHP extensions for PostgreSQL and other dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    git \
    unzip \
    zip \
    curl \
    && docker-php-ext-install pdo pdo_pgsql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy entire application
COPY . .

# Install dependencies without scripts first
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress --no-scripts

# Set proper permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Set Apache DocumentRoot to Laravel public folder
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Create a health check file to see if PHP is working
RUN echo "<?php echo 'PHP is working'; ?>" > /var/www/html/public/health.php

EXPOSE 80
CMD ["apache2-foreground"]