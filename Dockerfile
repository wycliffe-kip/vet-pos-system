# ------------------------------
# Stage 1: Build Angular Frontend
# ------------------------------
FROM node:20 as frontend-builder

# Set working directory
WORKDIR /app

# Copy Angular project
COPY public/view/vet-pos-dev/package.json public/view/vet-pos-dev/package-lock.json ./vet-pos-dev/
WORKDIR /app/vet-pos-dev

# Install dependencies and build Angular
RUN npm install
RUN npm run build -- --configuration production

# ------------------------------
# Stage 2: Laravel Backend
# ------------------------------
FROM php:8.2-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install system dependencies
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libonig-dev libxml2-dev libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd \
    && apt-get clean

# Set working directory
WORKDIR /var/www/html

# Copy Laravel backend
COPY . .

# Copy Angular build from stage 1 to public folder
COPY --from=frontend-builder /app/vet-pos-dev/dist/vet-pos-dev ./public/dist

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Expose port (Render automatically sets $PORT)
EXPOSE 10000

# Run Laravel server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
