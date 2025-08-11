<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\TrackerController;

// Breeze keeps the default welcome page; we point '/' to it
Route::get('/', function () {
    return view('welcome');
});

Route::get('/health', fn() => response('ok', 200));

Route::get('/status', function () {
    $checks = ['app' => 'OK', 'db' => 'UNKNOWN', 'migrations' => 'UNKNOWN'];
    try { DB::select('SELECT 1'); $checks['db'] = 'Connected'; } catch (\Throwable $e) { $checks['db'] = 'ERROR'; }
    try { $m = DB::table('migrations')->count(); $checks['migrations'] = $m>=0 ? 'OK':'MISSING'; } catch (\Throwable $e) { $checks['migrations'] = 'ERROR'; }
    return response()->json(['app' => 'Laravel', 'status'=>$checks, 'timestamp'=>now()->toIso8601String()]);
});

// Tracker endpoints (support GET and POST)
Route::match(['GET','POST'], '/announce', [TrackerController::class, 'announce']);
Route::match(['GET','POST'], '/scrape',   [TrackerController::class, 'scrape']);
