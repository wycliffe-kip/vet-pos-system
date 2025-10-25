# Stage 1: Build Angular frontend
FROM node:20 AS frontend-builder

# Set working directory
WORKDIR /app/vet-pos-dev

# Copy only package files first (for caching)
COPY public/view/vet-pos-dev/package.json public/view/vet-pos-dev/package-lock.json ./

# Install Angular dependencies
RUN npm install

# Copy the rest of the Angular project
COPY public/view/vet-pos-dev/ .

# Build Angular production bundle
RUN npm run build -- --configuration production

# Stage 2: PHP / Laravel backend
FROM php:8.2-apache

# Install system dependencies for Laravel & PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    zip unzip git curl libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd \
    && a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy Laravel project files
COPY . .

# Copy Angular production build to Laravel public folder
COPY --from=frontend-builder /app/vet-pos-dev/dist/vet-pos-dev ./public/vet-pos-dev

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
