# ==========================
# 1️⃣ Stage 1: Build Angular frontend
# ==========================
FROM node:18 AS build-frontend

WORKDIR /app

# Copy package.json and package-lock.json first
COPY public/view/vet-pos-dev/package*.json ./vet-pos-dev/

# Move into Angular project
WORKDIR /app/vet-pos-dev

# Install dependencies
RUN npm install

# Copy rest of Angular source code
COPY public/view/vet-pos-dev/ ./

# Build Angular
RUN npm run build --verbose

# ==========================
# 2️⃣ Stage 2: Laravel + Apache
# ==========================
FROM php:8.2-apache

# Install necessary PHP extensions
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy Laravel project files
COPY . .

# Copy built Angular files into Laravel's public folder
COPY --from=build-frontend /app/vet-pos-dev/dist/vet-pos-dev/ ./public/

# Fix permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Replace Apache default config with your app's
COPY ./docker/vetpos.conf /etc/apache2/sites-available/000-default.conf

# Expose port 84
EXPOSE 84

# Start Apache
CMD ["apache2-foreground"]
