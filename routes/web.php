<?php

use Illuminate\Support\Facades\Route;

Route::get('/health', fn() => response('OK', 200));
Route::get('/', fn() => view('welcome'));
