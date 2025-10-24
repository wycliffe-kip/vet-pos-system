# Use PHP with Apache
FROM php:8.2-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev zip unzip git curl libpng-dev libonig-dev libxml2-dev \
    nodejs npm && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable required PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy the Laravel project files
COPY . /var/www/html

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install Laravel dependencies (no dev packages)
RUN composer install --no-dev --optimize-autoloader

# Build Angular frontend inside the nested folder
WORKDIR /var/www/html/public/view/vet-pos-dev
RUN npm install && npm run build

# Return to Laravel root directory
WORKDIR /var/www/html

# Ensure correct permissions for Laravel storage
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Apache configuration for Laravel
RUN echo '<Directory /var/www/html/public>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-available/laravel.conf && \
    a2enconf laravel

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
