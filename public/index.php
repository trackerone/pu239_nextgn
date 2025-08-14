<?php

define('LARAVEL_START', microtime(true));

require __DIR__.'/../vendor/autoload.php';

$app = require_once __DIR__.'/../bootstrap/app.php';

$kernel = $app->handleRequest(
    $app->make(Illuminate\Contracts\Http\Kernel::class)
)->send();
