#!/bin/bash
set -e

# ----------------------------
# CONFIGURATION
# ----------------------------

# GitHub repo info
REPO="git@github.com:wycliffe-kip/vet-pos-system.git"
BRANCH="main"

# Render service info
RENDER_APP_NAME="vet-pos-system-1" # your Render service name
RENDER_APP_URL="https://vet-pos-system-1.onrender.com"

# Render DB info
RENDER_DB_USER="vet_pos_system_user"
RENDER_DB_PASS="6UHJWN8Lfs9KKGtQx00bJ5Nq3pPHQ6Pl"
RENDER_DB_HOST="dpg-d3tsj20dl3ps73enbqig-a.oregon-postgres.render.com"
RENDER_DB_NAME="vet_pos_system"
RENDER_DB_PORT="5432"

# Local DB info
LOCAL_DB_USER="rono_pos"
LOCAL_DB_PASS="postgres"
LOCAL_DB_HOST="127.0.0.1"
LOCAL_DB_NAME="vet_pos_system"
LOCAL_DB_PORT="5432"

# ----------------------------
# 1️⃣ Push code to GitHub
# ----------------------------
echo "🔹 Checking for local changes..."
git add .
git commit -m "Deploy Laravel + Angular SPA to Render" || echo "No changes to commit."

echo "🔹 Pushing to GitHub..."
git push $REPO $BRANCH
echo "✅ Code pushed to GitHub"

# ----------------------------
# 2️⃣ Export local DB
# ----------------------------
echo "🔹 Exporting local PostgreSQL database..."
PGPASSWORD=$LOCAL_DB_PASS pg_dump -U $LOCAL_DB_USER -h $LOCAL_DB_HOST -p $LOCAL_DB_PORT $LOCAL_DB_NAME > vetpos_local.sql
echo "✅ Local DB exported to vetpos_local.sql"

# ----------------------------
# 3️⃣ Upload DB to Render Shell
# ----------------------------
# Check if Render CLI is installed
if ! command -v render &> /dev/null; then
    echo "❌ Render CLI not found. Install it first: https://render.com/docs/cli"
    exit 1
fi

echo ""
echo "🔹 Uploading local SQL dump to Render Shell..."
render cp vetpos_local.sql $RENDER_APP_NAME:~/vetpos_local.sql
echo "✅ vetpos_local.sql uploaded"

echo ""
echo "🔹 Opening Render Shell to import database..."
echo "Inside Render Shell, run this command to import:"
echo "PGPASSWORD=$RENDER_DB_PASS psql -U $RENDER_DB_USER -h $RENDER_DB_HOST -d $RENDER_DB_NAME -f ~/vetpos_local.sql"
echo ""
render shell $RENDER_APP_NAME

# ----------------------------
# 4️⃣ Reminder for Render env vars
# ----------------------------
echo ""
echo "🔹 Make sure these environment variables are set in Render Dashboard:"
echo "APP_ENV=production"
echo "APP_DEBUG=false"
echo "APP_KEY=base64:/rEu/aOMyU5CCAYjx60+5PFA2KaVSQPIX/NkEZTNtfs="
echo "APP_URL=$RENDER_APP_URL"
echo "DB_CONNECTION=pgsql"
echo "DB_HOST=$RENDER_DB_HOST"
echo "DB_PORT=$RENDER_DB_PORT"
echo "DB_DATABASE=$RENDER_DB_NAME"
echo "DB_USERNAME=$RENDER_DB_USER"
echo "DB_PASSWORD=$RENDER_DB_PASS"
echo "SESSION_DRIVER=database"
echo "SESSION_DOMAIN=.vet-pos-system-1.onrender.com"
echo "SANCTUM_STATEFUL_DOMAINS=vet-pos-system-1.onrender.com"

echo "✅ Deployment steps complete!"
echo "Visit $RENDER_APP_URL to check your application."
