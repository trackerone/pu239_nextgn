<?php
// --- Force clear Laravel caches in immutable deploy envs (Render) ---
$cacheFiles = [
    __DIR__ . '/../bootstrap/cache/config.php',
    __DIR__ . '/../bootstrap/cache/packages.php',
    __DIR__ . '/../bootstrap/cache/services.php',
    __DIR__ . '/../bootstrap/cache/events.php',
];

// Remove all route cache variants (routes-v7.php, etc.)
foreach (glob(__DIR__ . '/../bootstrap/cache/routes-*.php') ?: [] as $routeCache) {
    @unlink($routeCache);
}

foreach ($cacheFiles as $file) {
    if (is_file($file)) {
        @unlink($file);
    }
}
// --- end: force clear ---
<?php

declare(strict_types=1);

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

require __DIR__.'/../vendor/autoload.php';

$app = require __DIR__.'/../bootstrap/app.php';
/*
|--------------------------------------------------------------------------
| Debug override (midlertidig)
|--------------------------------------------------------------------------
| Denne blok fanger alle exceptions og viser rå besked + fil + linje.
| Fjern den igen, når fejlen er fundet!
*/
set_exception_handler(function (Throwable $e) {
    http_response_code(500);
    header('Content-Type: text/plain');
    echo "ERR: " . $e->getMessage() . "\n";
    echo $e->getFile() . ":" . $e->getLine() . "\n";
    echo $e->getTraceAsString();
    exit(1);
});

$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
);

$response->send();

$kernel->terminate($request, $response);
