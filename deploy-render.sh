#!/bin/bash
set -e

# ----------------------------
# CONFIGURATION
# ----------------------------
REPO="git@github.com:wycliffe-kip/vet-pos-system.git"
BRANCH="main"

RENDER_APP_URL="https://vet-pos-system-1.onrender.com"

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
# 2️⃣ Deployment reminder
# ----------------------------
echo ""
echo "Render will now rebuild your service from GitHub automatically."
echo "✅ Deployment triggered. Visit $RENDER_APP_URL to check your application."
