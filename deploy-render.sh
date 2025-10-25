#!/bin/bash

# ===============================
# Deploy Laravel + Angular SPA to Render
# and push local PostgreSQL to Render
# ===============================

# ----- Local DB (to export) -----
LOCAL_DB_USER="rono_pos"
LOCAL_DB_PASS="postgres"
LOCAL_DB_HOST="127.0.0.1"
LOCAL_DB_PORT="5432"
LOCAL_DB_NAME="vet_pos_system"

# ----- Render DB (target) -----
RENDER_DB_USER="vet_pos_system_user"
RENDER_DB_PASS="6UHJWN8Lfs9KKGtQx00bJ5Nq3pPHQ6Pl"
RENDER_DB_HOST="dpg-d3tsj20dl3ps73enbqig-a"
RENDER_DB_PORT="5432"
RENDER_DB_NAME="vet_pos_system"

# ----- Render repo -----
RENDER_REPO="git@github.com:wycliffe-kip/vet-pos-system.git"
RENDER_BRANCH="main"

# ----- Laravel APP Key -----
APP_KEY="base64:/rEu/aOMyU5CCAYjx60+5PFA2KaVSQPIX/NkEZTNtfs="
APP_URL="https://vet-pos-system.onrender.com"

# ===============================
# 1️⃣ Push code to GitHub
# ===============================
echo "Adding and committing code..."
git add .
git commit -m "Deploy Laravel + Angular SPA to Render" || echo "No changes to commit."

echo "Pushing to GitHub repo..."
git push $RENDER_REPO $RENDER_BRANCH
if [ $? -ne 0 ]; then
    echo "❌ Failed to push code to GitHub."
    exit 1
fi
echo "✅ Code pushed to GitHub"

# ===============================
# 2️⃣ Deploy local DB directly to Render
# ===============================
echo "Streaming local DB directly to Render..."
PGPASSWORD=$LOCAL_DB_PASS pg_dump -U $LOCAL_DB_USER -h $LOCAL_DB_HOST -p $LOCAL_DB_PORT $LOCAL_DB_NAME | \
PGPASSWORD=$RENDER_DB_PASS psql -U $RENDER_DB_USER -h $RENDER_DB_HOST -d $RENDER_DB_NAME -p $RENDER_DB_PORT

if [ $? -ne 0 ]; then
    echo "❌ Failed to deploy database to Render."
    exit 1
fi
echo "✅ Database deployed to Render"

# ===============================
# 3️⃣ Reminder for Render environment variables
# ===============================
echo "Reminder: Make sure Render environment variables are set:"
echo "APP_ENV=production"
echo "APP_DEBUG=false"
echo "APP_KEY=$APP_KEY"
echo "APP_URL=$APP_URL"
echo "DB_CONNECTION=pgsql"
echo "DB_HOST=$RENDER_DB_HOST"
echo "DB_PORT=$RENDER_DB_PORT"
echo "DB_DATABASE=$RENDER_DB_NAME"
echo "DB_USERNAME=$RENDER_DB_USER"
echo "DB_PASSWORD=$RENDER_DB_PASS"
echo "SESSION_DRIVER=database"
echo "SESSION_DOMAIN=.vet-pos-system.onrender.com"
echo "SANCTUM_STATEFUL_DOMAINS=vet-pos-system.onrender.com"

echo "✅ Deployment process complete!"
echo "Visit $APP_URL"
