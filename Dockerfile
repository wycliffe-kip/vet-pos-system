# Use PHP 8.2 with Apache
FROM php:8.2-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev zip unzip git curl libpng-dev libonig-dev libxml2-dev nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# Enable PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd

# Enable Apache rewrite
RUN a2enmod rewrite

# Fix Apache ServerName warning
RUN echo "ServerName vet-pos-system.onrender.com" >> /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html

# Copy entire Laravel project
COPY . /var/www/html

# Install composer dependencies
RUN curl -sS https://getcomposer.org/installer | php && \
    php composer.phar install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Build Angular frontend (inside public/view/vet-pos-dev)
RUN cd public/view/vet-pos-dev && npm install && npm run build && \
    cp -r dist/* ../../

# Configure Apache VirtualHost
RUN rm /etc/apache2/sites-enabled/000-default.conf && \
    echo '<VirtualHost *:80>\n\
    ServerAdmin webmaster@localhost\n\
    ServerName vet-pos-system.onrender.com\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/vetpos-error.log\n\
    CustomLog ${APACHE_LOG_DIR}/vetpos-access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/vetpos.conf && \
    a2ensite vetpos.conf

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose web port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
