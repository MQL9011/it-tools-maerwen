#!/bin/bash
set -euo pipefail

# This script is kept for manual deployment reference only.
# Automated deployment is handled by GitHub Actions (build on GitHub, scp to server).

SITE_DIR="/opt/1panel/www/sites/tool.maerwen.com"

echo "Site directory: $SITE_DIR"
echo "Files deployed:"
ls -la "$SITE_DIR"/ | head -20
echo "Deploy status: OK"
