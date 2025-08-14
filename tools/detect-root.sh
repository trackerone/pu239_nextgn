#!/bin/sh
set -e
ROOT="/app"
# If artisan exists here, assume this is the root
if [ -f "$ROOT/artisan" ]; then
  echo "$ROOT"
  exit 0
fi
# Try to find an artisan in a subdirectory
CANDIDATE="$(find "$ROOT" -maxdepth 2 -type f -name artisan 2>/dev/null | head -n1)"
if [ -n "$CANDIDATE" ]; then
  DIR="$(dirname "$CANDIDATE")"
  echo "$DIR"
  exit 0
fi
# Fallback to /app
echo "$ROOT"
