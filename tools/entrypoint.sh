#!/usr/bin/env bash
set -euo pipefail
ROOT=$(/app/tools/detect-root.sh)
cd "$ROOT"
echo "[entrypoint] Using root: $ROOT"

if [[ -f "artisan" && -f "bootstrap/app.php" ]]; then
  echo "[entrypoint] Laravel detected. Starting server..."
  exec php artisan serve --host=0.0.0.0 --port=8000
else:
  echo "[entrypoint] Warning: bootstrap/app.php eller artisan mangler i $ROOT"
  echo "[entrypoint] Indhold af $ROOT:"
  ls -la
  # Keep container alive to inspect logs on Render
  exec php -S 0.0.0.0:8000 -t public 2>/dev/null || sleep 3600
fi
