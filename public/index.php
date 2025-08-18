<?php
declare(strict_types=1);
// --- runtime fixes for Render/Docker ---
// Brug /tmp som system-temp hvis ikke sat
if (!ini_get('sys_temp_dir')) {
    @ini_set('sys_temp_dir', '/tmp');
}

// Sikr Laravel-mapper findes (ellers advarer tempnam)
$dirs = [
    __DIR__ . '/../storage/framework/cache',
    __DIR__ . '/../storage/framework/sessions',
    __DIR__ . '/../storage/framework/views',
    __DIR__ . '/../bootstrap/cache',
];

foreach ($dirs as $d) {
    if (!is_dir($d)) {
        @mkdir($d, 0777, true);
    }
}
// --- end runtime fixes ---
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
