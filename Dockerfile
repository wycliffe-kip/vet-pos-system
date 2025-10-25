# ----------------------------
# Base image
# ----------------------------
FROM php:8.2-apache

# ----------------------------
# Install PHP + PostgreSQL + Composer dependencies
# ----------------------------
RUN apt-get update && apt-get install -y \
    libpq-dev \
    git \
    unzip \
    zip \
    curl \
    && docker-php-ext-install pdo pdo_pgsql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# ----------------------------
# Copy Laravel + pre-built Angular
# ----------------------------
COPY . .

# ----------------------------
# Install PHP dependencies
# ----------------------------
RUN composer install --no-dev --optimize-autoloader

# ----------------------------
# Set permissions for storage & cache
# ----------------------------
RUN chown -R www-data:www-data storage bootstrap/cache

# ----------------------------
# Set Apache DocumentRoot to Laravel public folder
# ----------------------------
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# ----------------------------
# Expose port
# ----------------------------
EXPOSE 80

# ----------------------------
# Start Apache
# ----------------------------
CMD ["apache2-foreground"]
