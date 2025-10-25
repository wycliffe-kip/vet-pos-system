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

# Copy only composer files first (for caching)
COPY composer.json composer.lock ./

# Install dependencies without running scripts
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress --no-scripts

# Copy the rest of the application
COPY . .

# Now run the post-install scripts manually
RUN composer run-script post-autoload-dump

# Or run the specific artisan command
RUN php artisan package:discover --ansi

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/vetpos.conf

EXPOSE 84
CMD ["apache2-foreground"]