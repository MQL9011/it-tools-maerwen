#!/bin/bash
set -euo pipefail

PROJECT_DIR="/home/web/it-tools-maerwen"
SITE_DIR="/opt/1panel/www/sites/tool.maerwen.com"

cd "$PROJECT_DIR"

# Install pnpm if not available
if ! command -v pnpm &> /dev/null; then
    npm install -g pnpm
fi

# Install dependencies
pnpm install --frozen-lockfile

# Build
pnpm build

# Deploy built files
rm -rf "$SITE_DIR"/*
cp -r dist/* "$SITE_DIR"/

echo "Deploy completed at $(date)"
