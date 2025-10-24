# ===============================
# 1️⃣ Base image with PHP + Apache
# ===============================
FROM php:8.2-apache

# ===============================
# 2️⃣ Install required system packages
# ===============================
RUN apt-get update && apt-get install -y \
    libpq-dev zip unzip git curl \
    libpng-dev libonig-dev libxml2-dev \
    nodejs npm

# Enable required PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd

# Enable Apache rewrite for Laravel routes
RUN a2enmod rewrite

# ===============================
# 3️⃣ Set working directory
# ===============================
WORKDIR /var/www/html

# ===============================
# 4️⃣ Copy project files
# ===============================
COPY . /var/www/html

# ===============================
# 5️⃣ Install Composer dependencies
# ===============================
RUN curl -sS https://getcomposer.org/installer | php && \
    php composer.phar install --no-dev --optimize-autoloader

# ===============================
# 6️⃣ Build Angular frontend (inside public/)
# ===============================
RUN cd public && npm install && npm run build

# ===============================
# 7️⃣ Configure Apache VirtualHost
# ===============================
RUN rm /etc/apache2/sites-enabled/000-default.conf && \
    echo '<VirtualHost *:80>\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/vetpos-error.log\n\
    CustomLog ${APACHE_LOG_DIR}/vetpos-access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/vetpos.conf && \
    a2ensite vetpos.conf && \
    a2enmod rewrite

# ===============================
# 8️⃣ Set permissions for Laravel
# ===============================
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# ===============================
# 9️⃣ Expose port 80
# ===============================
EXPOSE 80

# ===============================
# 🔟 Start Apache
# ===============================
CMD ["apache2-foreground"]
