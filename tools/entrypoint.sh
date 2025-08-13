#!/bin/sh
set -e
ROOT=$(/bin/sh /app/tools/detect-root.sh)
cd "$ROOT"
echo "[entrypoint] Using root: $ROOT"
if [ -f "artisan" ] && [ -f "bootstrap/app.php" ]; then
  echo "[entrypoint] Laravel detected. Starting server..."
  exec php artisan serve --host=0.0.0.0 --port=8000
else
  echo "[entrypoint] Warning: bootstrap/app.php eller artisan mangler i $ROOT"
  ls -la
  exec php -S 0.0.0.0:8000 -t public 2>/dev/null || sleep 3600
fi
