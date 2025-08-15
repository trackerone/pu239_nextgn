<?php

use Illuminate\Support\Facades\Route;

Route::get('/health', fn () => response()->json(['ok' => true, 'ts' => now()->toISOString()]));
Route::get('/', fn () => view('welcome'));
