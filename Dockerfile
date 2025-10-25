# -----------------------------
# Stage 1: Build Angular frontend
# -----------------------------
FROM node:20 AS frontend-builder

WORKDIR /app/frontend

# Copy Angular project package files
COPY public/view/vet-pos-dev/package.json public/view/vet-pos-dev/package-lock.json ./

# Install Angular dependencies
RUN npm ci

# Copy full Angular source code
COPY public/view/vet-pos-dev/ ./

# Build Angular for production
RUN npm run build -- --output-path=dist --configuration=production

# -----------------------------
# Stage 2: Build Laravel backend
# -----------------------------
FROM php:8.2-apache

# Install PHP extensions
RUN apt-get update && apt-get install -y \
    libpq-dev \
    git \
    unzip \
    zip \
    curl \
    && docker-php-ext-install pdo pdo_pgsql

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy Laravel backend code
COPY . .

# Copy Angular build to Laravel public folder
COPY --from=frontend-builder /app/frontend/dist /var/www/html/public

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Set Apache DocumentRoot to public
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/vetpos.conf

# Expose port 10000 (Render uses this for web services)
EXPOSE 10000

# Start Apache in the foreground
CMD ["apache2-foreground"]
