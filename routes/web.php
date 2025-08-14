<?php

use Illuminate\Support\Facades\Route;

// Health endpoint for uptime checks
Route::get('/healthz', function () {
    return response('OK', 200);
});
