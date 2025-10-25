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

# Copy composer files first
COPY composer.json composer.lock ./

# Debug: List files to verify composer.json exists
RUN ls -la

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Debug: Verify vendor directory was created
RUN ls -la vendor/

# Copy the rest of the application
COPY . .

# Set proper permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Set Apache DocumentRoot to Laravel public folder
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Debug: Final check of vendor directory
RUN ls -la /var/www/html/vendor/

EXPOSE 80
CMD ["apache2-foreground"]