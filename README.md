# Pu-239 Next Generation

This is the upgraded Pu-239 project, built with Laravel and packaged in Docker for easy hosting on Render.

## 🌍 Online Demo
If deployed on Render, your URL will look like: `https://<service>.onrender.com`  
Health-check: `/health`

## 🚀 Technology Stack
- Laravel (PHP 8.3)
- Docker (PHP-FPM + Caddy web server)
- PostgreSQL (Render free plan for development/testing)
- Render Free tier (750 hours/month, 512 MB RAM)

## 📦 Project Structure
```
├── Dockerfile
├── render.yaml          # optional if you use it
├── start.sh
├── deploy/
│   └── Caddyfile
└── overlay/
    ├── routes/web.php
    ├── app/
    │   ├── Http/Controllers/TrackerController.php
    │   ├── Http/Middleware/VerifyCsrfToken.php
    │   └── Services/Bencode.php
    ├── config/tracker.php
    ├── database/migrations/2025_08_10_000000_create_peers_table.php
    ├── database/migrations/2025_08_10_000001_create_sessions_table.php
    └── resources/views/...
```

## 🔑 First-time Setup on Render
1. Connect repo → New → Web Service (Free) → Deploy.
2. Set env vars:
   - `APP_URL=https://<your>.onrender.com`
   - `SESSION_DRIVER=file`
   - Tracker toggles (optional):
     - `TRACKER_MODE=embedded` (default)
     - `EXTERNAL_ANNOUNCE_URL=udp://your-udp-host:6969/announce`
3. Manual Deploy → Clear build cache & Redeploy.

## 🧪 Tracker Modes
- **embedded**: HTTP `/announce` and `/scrape` handled by this app.
- **external**: App redirects to `EXTERNAL_ANNOUNCE_URL` (HTTP), or returns a bencoded hint for UDP.

## 🖥 Local Development
Build and run:
```bash
docker build -t pu239 .
docker run -p 8080:8080 pu239
```
