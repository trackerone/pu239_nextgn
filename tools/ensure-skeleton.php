<?php
/**
 * ensure-skeleton.php
 *
 * Creates minimal Laravel 11 skeleton files if missing:
 *  - bootstrap/app.php
 *  - public/index.php
 *  - ensures bootstrap/cache directory exists
 */

$root = getcwd();

$bootstrapDir = $root . '/bootstrap';
$publicDir    = $root . '/public';
$cacheDir     = $root . '/bootstrap/cache';

if (!is_dir($bootstrapDir)) {
    @mkdir($bootstrapDir, 0777, true);
}
if (!is_dir($publicDir)) {
    @mkdir($publicDir, 0777, true);
}
if (!is_dir($cacheDir)) {
    @mkdir($cacheDir, 0777, true);
}

// Laravel 11 default-ish bootstrap/app.php
$bootstrapApp = <<<'PHP'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // register global middleware here if needed
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // customize exception rendering/handling here if needed
    })
    ->create();
PHP;

$bootstrapPath = $bootstrapDir . '/app.php';
if (!file_exists($bootstrapPath)) {
    file_put_contents($bootstrapPath, $bootstrapApp);
    echo "[ensure] Created bootstrap/app.php" . PHP_EOL;
} else {
    echo "[ensure] bootstrap/app.php already exists" . PHP_EOL;
}

// public/index.php compatible with Laravel 11
$publicIndex = <<<'PHP'
<?php

define('LARAVEL_START', microtime(true));

require __DIR__.'/../vendor/autoload.php';

$app = require_once __DIR__.'/../bootstrap/app.php';

$app->handleRequest(
    $request = Illuminate\Http\Request::capture()
)->send();
PHP;

$publicIndexPath = $publicDir . '/index.php';
if (!file_exists($publicIndexPath)) {
    file_put_contents($publicIndexPath, $publicIndex);
    echo "[ensure] Created public/index.php" . PHP_EOL;
} else {
    echo "[ensure] public/index.php already exists" . PHP_EOL;
}

// Ensure cache dir is writable
@chmod($cacheDir, 0777);
