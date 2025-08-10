# Pu-239 Next Generation

This is the upgraded Pu-239 project, built with Laravel and packaged in Docker for easy hosting on [Render](https://render.com/).

## 🌍 Online Demo
**URL:** [https://pu239-nextgn.onrender.com](https://pu239-nextgn.onrender.com)  
**Health-check:** [https://pu239-nextgn.onrender.com/health](https://pu239-nextgn.onrender.com/health)

---

## 🚀 Technology Stack
- **Laravel** (PHP 8.3)
- **Docker** (PHP-FPM + Caddy web server)
- **PostgreSQL** (Render free plan for development/testing)
- **Render Free tier** (750 hours/month, 512 MB RAM)

---

## 📦 Project Structure
├── Dockerfile # Builds Laravel + PHP + Caddy
├── render.yaml # Render config (web + db)
├── start.sh # Starts the app + runs DB migrations
├── deploy/
│ └── Caddyfile # Caddy web server config
└── README.md

yaml
Kopiér
Rediger

---

## 🔑 First-time Setup on Render
1. **Connect the repository to Render**
   - Log in to Render → New + → **Web Service**
   - Select this repository, choose **Free** plan
   - Render reads `render.yaml` and provisions both the web service and the database

2. **Environment variables**
   - Render automatically sets DB variables
   - Set `APP_URL=https://pu239-nextgn.onrender.com`
   - Set `APP_ENV=production` (if not already set)

3. **Deploy**
   - First deployment takes 1-2 minutes
   - When finished → visit the provided URL

---

## 🖥 Local Development
### Requirements
- Docker + Docker Compose
- Node.js (for building assets)
- Composer

### Run locally
```bash
# Clone repository
git clone https://github.com/trackerone/pu239_nextgn.git
cd pu239_nextgn

# Build and start container
docker build -t pu239 .
docker run -p 8080:8080 pu239

# Laravel will now run at http://localhost:8080
Environment file
Create .env in the project root (use .env.example as a template).
For local Postgres:

bash
Kopiér
Rediger
docker run --name pu239-db -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=pu239 -p 5432:5432 -d postgres
Then set DB_HOST=host.docker.internal in .env.

📋 Notes
Free Render instances sleep after inactivity → first request may be slow (cold start)

Postgres on free plan is for development only (limited resources)

For production → upgrade instance + database
