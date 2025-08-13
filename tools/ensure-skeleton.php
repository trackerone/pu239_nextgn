<?php
// tools/ensure-skeleton.php
// Creates minimal Laravel 11 bootstrap/app.php and public/index.php if missing,
// using existing routes in routes/web.php and routes/console.php if present.

function mkdir_p($dir) {
    if (!is_dir($dir)) mkdir($dir, 0777, true);
}

$root = getcwd();

// 1) bootstrap/app.php
$bootstrapDir = $root . '/bootstrap';
$bootstrapFile = $bootstrapDir . '/app.php';
if (!file_exists($bootstrapFile)) {
    mkdir_p($bootstrapDir);
    $routesWeb = file_exists($root.'/routes/web.php') ? "__DIR__.'/../routes/web.php'" : 'null';
    $routesConsole = file_exists($root.'/routes/console.php') ? "__DIR__.'/../routes/console.php'" : 'null';

    $appPhp = <<<PHP
    <?php

    use Illuminate\Foundation\Application;
    use Illuminate\Foundation\Configuration\Exceptions;
    use Illuminate\Foundation\Configuration\Middleware;

    return Application::configure(basePath: dirname(__DIR__))
        ->withRouting(
            web: {$routesWeb},
            commands: {$routesConsole},
            health: '/up',
        )
        ->withMiddleware(function (Middleware \$middleware) {
            // add middleware here if needed
        })
        ->withExceptions(function (Exceptions \$exceptions) {
            // customize exception handling
        })->create();
    PHP;
    file_put_contents($bootstrapFile, $appPhp);
    echo "[ensure] Created bootstrap/app.php\n";
} else {
    echo "[ensure] bootstrap/app.php already exists\n";
}

// 2) public/index.php
$publicDir = $root . '/public';
$publicIndex = $publicDir . '/index.php';
if (!file_exists($publicIndex)) {
    mkdir_p($publicDir);
    $indexPhp = <<<PHP
    <?php

    define('LARAVEL_START', microtime(true));

    require __DIR__.'/../vendor/autoload.php';

    $app = require_once __DIR__.'/../bootstrap/app.php';

    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

    $response = $kernel->handle(
        $request = Illuminate\Http\Request::capture()
    )->send();

    $kernel->terminate($request, $response);
    PHP;
    file_put_contents($publicIndex, $indexPhp);
    echo "[ensure] Created public/index.php\n";
} else {
    echo "[ensure] public/index.php already exists\n";
}
