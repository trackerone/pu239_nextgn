<?php

declare(strict_types=1);

use Illuminate\Http\Request;

require __DIR__ . '/../vendor/autoload.php';

$app = require __DIR__ . '/../bootstrap/app.php';

$response = $app->handleRequest(Request::capture());
$response->send();
