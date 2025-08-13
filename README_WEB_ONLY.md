# Web-only Fix (GitHub + Render)

Du kan ikke køre noget lokalt – fair. Denne pakke gør alt via Docker build på Render.
Tricket er: vi **retter composer.json inde i buildet** og kører `composer update` dér.

## Hvad du gør (kun via GitHub web UI)
1. Upload disse filer til repo-roden:
   - `Dockerfile` (den i denne pakke)
   - `.dockerignore`
   - `tools/fix-composer.php` (mappe + fil)
2. Commit direkte i GitHub web.
3. Render bygger automatisk. Under build vil følgende ske:
   - `fix-composer.php` kører og fjerner direkte `illuminate/*`
   - sikrer `"laravel/framework": "^11.0"`
   - sætter `conflict` for at blokere `illuminate/*` 12.x
   - `composer update` kører **i buildet** og skriver en kompatibel `composer.lock`
   - resten af koden kopieres ind, og `php artisan config:cache` kører

## Vigtige noter
- Du behøver **ikke** have `composer.lock` i repo. Det genereres i buildet.
- Hvis nogle dev-dependencies stadig udløser constraints, så fjern dem midlertidigt i `composer.json` (web UI) eller pin deres version til noget, der understøtter Laravel 11.
- Hvis du mangler PHP extensions, kan Dockerfile udvides (fx `pdo_mysql`, `bcmath`). Sig til, så laver jeg en v3.

## Hvorfor virker det?
Fordi konflikten opstår, når Composer forsøger at installere **både** `laravel/framework` og direkte `illuminate/*` i forskellige majors.
Ved at rette `composer.json` **før** dependency-resolve inde i buildet, undgår vi konflikten uden lokal CLI.
