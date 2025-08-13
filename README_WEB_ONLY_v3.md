# Web-only Fix v3 (no wildcard conflicts)

Denne version fjerner IKKE længere en wildcard conflict for `illuminate/*` (Composer accepterer ikke wildcards i `conflict`).
I stedet:
- fjerner vi direkte `illuminate/*` i require/require-dev
- sikrer `laravel/framework:^11.0`
- rydder evt. gamle `conflict`-felter med `illuminate/*` hvis de findes

## Brug (kun via GitHub/Render)
1. Upload:
   - `Dockerfile`
   - `.dockerignore`
   - `tools/fix-composer.php`
2. Commit — Render bygger automatisk.
3. Buildstep kører fix-skriptet og derefter `composer update` inden resten af koden kopieres ind.
