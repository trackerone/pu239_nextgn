<?php
declare(strict_types=1);

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

require __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';

/** @var \Illuminate\Contracts\Http\Kernel $kernel */
$kernel = $app->make(Kernel::class);

$response = $kernel->handle(
    $request = Request::capture()
);

$response->send();

$kernel->terminate($request, $response);
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
