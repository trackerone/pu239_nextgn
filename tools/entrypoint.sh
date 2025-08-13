    #!/bin/sh
    set -e
    ROOT=$(/bin/sh /app/tools/detect-root.sh)
    cd "$ROOT"
    echo "[entrypoint] Using root: $ROOT"

    # Ensure skeleton + writable dirs
    php /app/tools/ensure-skeleton.php

    # Ensure .env
    if [ ! -f ".env" ]; then
      if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "[entrypoint] Created .env from .env.example"
      else
        echo "[entrypoint] Creating minimal .env"
        cat > .env <<'EOF'
APP_NAME=Laravel
APP_ENV=production
APP_DEBUG=false
APP_URL=${RENDER_EXTERNAL_URL:-http://localhost}
LOG_CHANNEL=stderr
LOG_LEVEL=debug
SESSION_DRIVER=file
CACHE_STORE=file
DB_CONNECTION=mysql
DB_HOST=
DB_PORT=3306
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=
EOF
      fi
    fi
    # Force log to stderr
    if ! grep -q '^LOG_CHANNEL=' .env; then echo 'LOG_CHANNEL=stderr' >> .env; else sed -i 's/^LOG_CHANNEL=.*/LOG_CHANNEL=stderr/' .env; fi
    # Generate key if missing
    if ! grep -q '^APP_KEY=base64:' .env; then php artisan key:generate --force || true; fi

    # Permissions + caches
    mkdir -p bootstrap/cache storage/framework/{cache,sessions,views}
    chmod -R 777 bootstrap/cache storage || true
    if [ -f "artisan" ]; then
      php artisan config:clear || true
      php artisan route:clear || true
      php artisan view:clear || true
      php artisan config:cache || true
      php artisan route:cache || true
      php artisan view:cache || true
    fi

    if [ -f "artisan" ] && [ -f "bootstrap/app.php" ]; then
      echo "[entrypoint] Laravel detected. Starting server..."
      exec php artisan serve --host=0.0.0.0 --port=8000
    else
      echo "[entrypoint] Fallback: serving public/ (if present)"
      ls -la public || true
      exec php -S 0.0.0.0:8000 -t public 2>/dev/null || sleep 3600
    fi
