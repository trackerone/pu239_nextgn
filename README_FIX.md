# Laravel 11 Conflict Fix Pack

This pack fixes the common Composer conflict where `laravel/framework` (v11) cannot be installed
alongside direct `illuminate/*` packages. Laravel's framework **replaces** those components,
so they should not be directly required.

## What’s inside
- `Dockerfile` — cache-friendly, respects `composer.lock`, and runs `artisan config:cache` only after install.
- `.dockerignore` — keeps your image small and builds fast.
- `tools/fix-composer.php` — **safe editor** that updates your existing `composer.json`:
    - Removes direct `illuminate/*` from `require` and `require-dev`
    - Ensures `"laravel/framework": "^11.0"` is present
    - Adds `conflict: { "illuminate/*": ">=12.0" }` to block 12.x against Laravel 11
    - Preserves all other dependencies

## Quick usage

1. Copy the contents of this pack into your project root (keep folder structure).
   - `Dockerfile` and `.dockerignore` should be at repo root.
   - `tools/fix-composer.php` should be in `tools/` next to `composer.json` (root).

2. Run the fixer:
   ```bash
   php tools/fix-composer.php
   ```

3. Review and update dependencies locally:
   ```bash
   composer update laravel/framework --with-all-dependencies
   composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader
   ```

4. Commit `composer.json` and `composer.lock`.

5. Rebuild your image:
   ```bash
   docker build -t your-app:latest .
   ```

## Troubleshooting

- See which package forces an incompatible `illuminate/*` or blocks the framework:
  ```bash
  composer why illuminate/contracts
  composer why-not laravel/framework 11.45.1
  ```

- If a **dev** package is pulling in incompatible versions, remember that `--no-dev` does not remove
  constraint conflicts. Either update or temporarily remove the offending dev package.

- If you truly want to run **component mode** (without `laravel/framework`), don't use this pack —
  remove the framework and pin `illuminate/*` to the same major version instead.
