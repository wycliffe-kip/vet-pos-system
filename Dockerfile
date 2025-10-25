# Use official PHP + Apache image
FROM php:8.2-apache

# Install PHP extensions for PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    git \
    unzip \
    zip \
    curl \
    && docker-php-ext-install pdo pdo_pgsql

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy Laravel backend + pre-built Angular frontend
COPY . .

# Make storage & cache directories writable
RUN chown -R www-data:www-data storage bootstrap/cache

# Set Apache DocumentRoot to Laravel public folder
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Expose web port
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
