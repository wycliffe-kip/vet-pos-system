# ---------------------------
# Stage 1: Build Angular Frontend
# ---------------------------
FROM node:20 AS frontend-builder

# Set working directory inside container
WORKDIR /app/vet-pos-dev

# Copy package.json & package-lock.json
COPY public/view/vet-pos-dev/package.json public/view/vet-pos-dev/package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the Angular source code
COPY public/view/vet-pos-dev/ ./

# Build Angular for production
RUN npm run build -- --configuration production

# ---------------------------
# Stage 2: Setup Laravel Backend + Serve
# ---------------------------
FROM php:8.2-apache

# Install system dependencies for Laravel & PostgreSQL
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libonig-dev libxml2-dev libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd

# Set working directory for Laravel app
WORKDIR /var/www/html

# Copy Laravel backend
COPY . .

# Copy Angular build from previous stage to Laravel public folder
COPY --from=frontend-builder /app/vet-pos-dev/dist/vet-pos-dev ./public/vet-pos-dev

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set correct permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
