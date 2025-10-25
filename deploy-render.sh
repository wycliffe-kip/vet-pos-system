#!/bin/bash

# -------------------------------
# Deploy Laravel + Angular SPA to Render
# -------------------------------

# Render service name
SERVICE_NAME="vet-pos-system"
REPO_URL="<YOUR_GITHUB_REPO_URL>"
BRANCH="main"
REGION="oregon"

# PostgreSQL credentials (replace with your Render DB)
# DB_HOST="<POSTGRES_HOST>"
# DB_PORT="5432"
# DB_DATABASE="<POSTGRES_DB>"
# DB_USERNAME="<POSTGRES_USER>"
# DB_PASSWORD="<POSTGRES_PASSWORD>"

DB_CONNECTION=pgsql
DB_HOST=dpg-d3tsj20dl3ps73enbqig-a
DB_PORT=5432
DB_DATABASE=vet_pos_system
DB_USERNAME=vet_pos_system_user
DB_PASSWORD=6UHJWN8Lfs9KKGtQx00bJ5Nq3pPHQ6Pl

# Laravel env vars
APP_KEY="base64:/rEu/aOMyU5CCAYjx60+5PFA2KaVSQPIX/NkEZTNtfs="
APP_URL="https://vet-pos-system.onrender.com"

# -------------------------------
# Login to Render
# -------------------------------
echo "Logging in to Render..."
render login

# -------------------------------
# Create Render service (if not exists)
# -------------------------------
echo "Creating Render web service..."
render services create web \
  --name "$SERVICE_NAME" \
  --env php \
  --plan free \
  --region "$REGION" \
  --repo "$REPO_URL" \
  --branch "$BRANCH" \
  --build-command "composer install --no-dev --optimize-autoloader && php artisan migrate --force" \
  --start-command "php artisan serve --host=0.0.0.0 --port=\$PORT"

# -------------------------------
# Set environment variables
# -------------------------------
echo "Setting environment variables..."
render env create --service "$SERVICE_NAME" \
  APP_ENV=production \
  APP_DEBUG=false \
  APP_KEY="$APP_KEY" \
  APP_URL="$APP_URL" \
  DB_CONNECTION=pgsql \
  DB_HOST="$DB_HOST" \
  DB_PORT="$DB_PORT" \
  DB_DATABASE="$DB_DATABASE" \
  DB_USERNAME="$DB_USERNAME" \
  DB_PASSWORD="$DB_PASSWORD" \
  SESSION_DRIVER=database \
  SESSION_DOMAIN=".vet-pos-system.onrender.com" \
  SANCTUM_STATEFUL_DOMAINS="vet-pos-system.onrender.com"

# -------------------------------
# Deploy current code
# -------------------------------
echo "Deploying current code to Render..."
git add .
git commit -m "Deploy update to Render" || echo "No changes to commit."
git push origin "$BRANCH"

echo "✅ Deployment triggered! Visit $APP_URL"
