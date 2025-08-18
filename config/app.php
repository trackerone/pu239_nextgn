<?php

use Illuminate\Support\Facades\Facade;
use Illuminate\Support\ServiceProvider;

return [
    'name' => env('APP_NAME', 'Laravel'),
    'env' => env('APP_ENV', 'production'),
    'debug' => (bool) env('APP_DEBUG', false),

    'url' => env('APP_URL', 'http://localhost'),
    'asset_url' => env('ASSET_URL'),

    'timezone' => env('APP_TIMEZONE', 'UTC'),
    'locale' => env('APP_LOCALE', 'en'),
    'fallback_locale' => env('APP_FALLBACK_LOCALE', 'en'),
    'faker_locale' => 'en_US',

    'key' => env('APP_KEY'),
    'cipher' => 'AES-256-CBC',

    // VIGTIGT: registrerer bl.a. View- og Filesystem-serviceproviders
    'providers' => ServiceProvider::defaultProviders()->merge([
        // Egne providers kan tilføjes her
    ])->toArray(),

    'aliases' => Facade::defaultAliases()->merge([
        // Egne aliaser kan tilføjes her
    ])->toArray(),
];
