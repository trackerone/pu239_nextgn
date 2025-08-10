<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

Route::get('/', function () {
    return view('home');
});

Route::get('/status', function () {
    $app = config('app.name', 'Pu-239 NextGen');
    $checks = [
        'app' => 'OK',
        'db' => 'UNKNOWN',
        'migrations' => 'UNKNOWN',
    ];

    // DB connectivity check
    try {
        DB::select('SELECT 1');
        $checks['db'] = 'Connected';
    } catch (\Throwable $e) {
        $checks['db'] = 'ERROR: ' . $e->getMessage();
    }

    // Migration table check
    try {
        $hasMigrations = DB::table('migrations')->count();
        $checks['migrations'] = $hasMigrations >= 0 ? 'OK' : 'MISSING';
    } catch (\Throwable $e) {
        $checks['migrations'] = 'ERROR: ' . $e->getMessage();
    }

    return response()->json([
        'app' => $app,
        'status' => $checks,
        'timestamp' => now()->toIso8601String(),
    ]);
});

Route::get('/health', fn() => response('ok', 200));
