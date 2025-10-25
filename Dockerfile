# ----------------------------
# Base image
# ----------------------------
FROM php:8.2-apache

# ----------------------------
# Install PHP extensions + tools
# ----------------------------
RUN apt-get update && apt-get install -y \
    libpq-dev \
    git \
    unzip \
    zip \
    curl \
    && docker-php-ext-install pdo pdo_pgsql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ----------------------------
# Enable Apache mod_rewrite
# ----------------------------
RUN a2enmod rewrite

# ----------------------------
# Set working directory
# ----------------------------
WORKDIR /var/www/html

# ----------------------------
# Copy Laravel + Angular build (already built)
# ----------------------------
COPY . .

# ----------------------------
# Install PHP dependencies (production)
# ----------------------------
RUN composer install --no-dev --optimize-autoloader

# ----------------------------
# Set storage & cache permissions
# ----------------------------
RUN chown -R www-data:www-data storage bootstrap/cache

# ----------------------------
# Set Apache DocumentRoot
# ----------------------------
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# ----------------------------
# Expose port 80
# ----------------------------
EXPOSE 80

# ----------------------------
# Start Apache in foreground
# ----------------------------
CMD ["apache2-foreground"]
