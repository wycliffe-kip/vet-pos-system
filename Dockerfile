# Use official PHP 8.2 + Apache image
FROM php:8.2-apache

# ----------------------------
# 1️⃣ Enable Apache mods
# ----------------------------
RUN a2enmod rewrite headers

# ----------------------------
# 2️⃣ Set working directory
# ----------------------------
WORKDIR /var/www/html

# ----------------------------
# 3️⃣ Copy Laravel app
# ----------------------------
COPY . .

# ----------------------------
# 4️⃣ Permissions for storage & cache
# ----------------------------
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# ----------------------------
# 5️⃣ Copy Apache config for SPA routing
# ----------------------------
COPY docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# ----------------------------
# 6️⃣ Install PHP extensions (PostgreSQL, etc.)
# ----------------------------
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# ----------------------------
# 7️⃣ Expose port
# ----------------------------
EXPOSE 80

# ----------------------------
# 8️⃣ Start Apache
# ----------------------------
CMD ["apache2-foreground"]
