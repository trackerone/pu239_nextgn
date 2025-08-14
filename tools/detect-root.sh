#!/bin/sh
set -e
if [ -f /app/artisan ] || [ -f /app/composer.json ]; then
  echo /app
  exit 0
fi
for d in /app/*; do
  if [ -d "$d" ] && [ -f "$d/composer.json" ]; then
    echo "$d"
    exit 0
  fi
done
echo /app
