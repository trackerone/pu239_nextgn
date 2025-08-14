<?php

use Illuminate\Support\Facades\Route;

Route::get('/healthz', function () {
    return response('OK', 200);
});
