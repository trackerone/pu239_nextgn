#!/bin/sh
set -e

# Simple heuristics to find the Laravel root (where artisan lives)
if [ -f "/app/artisan" ]; then
  echo "/app"
  exit 0
fi

# search maxdepth to avoid traversing the whole tree in CI
FOUND="$(find /app -maxdepth 2 -type f -name artisan | head -n 1 || true)"
if [ -n "$FOUND" ]; then
  echo "$(dirname "$FOUND")"
  exit 0
fi

# Fallback
echo "/app"
