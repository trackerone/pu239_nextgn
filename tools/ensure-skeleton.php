<?php

// Minimal Laravel 11 skeleton generator for containers
$base = dirname(__DIR__);

// dirs
@mkdir("$base/bootstrap/cache", 0775, true);
@mkdir("$base/public", 0775, true);
@mkdir("$base/routes", 0775, true);
@mkdir("$base/storage/framework/{cache,data,sessions,views}", 0775, true);

// bootstrap/app.php (Laravel 11 style)
$appPhp = <<<'PHP'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up'
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Place global middleware config here if needed
    })
    ->withExceptions(function ($exceptions) {
        // Custom exception rendering if needed
    })
    ->create();
PHP;
if (!file_exists("$base/bootstrap/app.php")) {
    file_put_contents("$base/bootstrap/app.php", $appPhp);
}

// public/index.php
$publicIndex = <<<'PHP'
<?php

define('LARAVEL_START', microtime(true));

require __DIR__.'/../vendor/autoload.php';

$app = require __DIR__.'/../bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
);

$response->send();
$kernel->terminate($request, $response);
PHP;
if (!file_exists("$base/public/index.php")) {
    file_put_contents("$base/public/index.php", $publicIndex);
}

// routes/web.php (simple OK and healthz)
if (!file_exists("$base/routes/web.php")) {
    file_put_contents("$base/routes/web.php", "<?php\nuse Illuminate\Support\Facades\Route;\nRoute::get('/', fn() => 'OK');\nRoute::get('/healthz', fn() => response('OK', 200));\n");
}

// routes/console.php (empty stub)
if (!file_exists("$base/routes/console.php")) {
    file_put_contents("$base/routes/console.php", "<?php\n");
}
