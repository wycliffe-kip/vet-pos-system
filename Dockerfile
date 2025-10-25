# ----------------------------
# 1️⃣ Build Stage: Node for Angular
# ----------------------------
FROM node:20 AS frontend-builder

WORKDIR /app

# Copy only package files for caching
COPY public/view/vet-pos-dev/package.json public/view/vet-pos-dev/package-lock.json ./

# Install Angular dependencies
RUN npm install

# Copy Angular source
COPY public/view/vet-pos-dev/ ./

# Build Angular for production
RUN npm run build -- --configuration production

# ----------------------------
# 2️⃣ Laravel + Apache Stage
# ----------------------------
FROM php:8.2-apache

# Enable Apache mods
RUN a2enmod rewrite headers

# Set working directory
WORKDIR /var/www/html

# Copy Laravel app
COPY . .

# Copy Angular build from frontend-builder
COPY --from=frontend-builder /app/dist /var/www/html/public/resources

# Copy Apache vhost
COPY docker/vetpos.conf /etc/apache2/sites-available/000-default.conf

# Install PHP extensions
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
