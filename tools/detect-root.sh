#!/bin/sh
set -e
# Find Laravel root (dir with artisan + composer.json), search depth up to 3
if [ -f "artisan" ] && [ -f "composer.json" ]; then
  pwd
  exit 0
fi
root=$(find . -maxdepth 3 -type f -name artisan -printf '%h\n' | while read d; do
  if [ -f "$d/composer.json" ]; then
    echo "$d"
    break
  fi
done)
if [ -z "$root" ]; then
  c=$(find . -maxdepth 3 -type f -name composer.json -printf '%h\n' | head -n1)
  if [ -n "$c" ]; then
    echo "$c"
    exit 0
  fi
  echo "."
  exit 0
fi
echo "$root"
