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

    /*
    |--------------------------------------------------------------------------
    | Providers & Aliases (Laravel 11 defaults)
    |--------------------------------------------------------------------------
    | Disse to linjer er vigtige. De tilføjer alle kerneproviders
    | (bl.a. ViewServiceProvider og FilesystemServiceProvider),
    | samt standard-facade aliaser.
    */
    'providers' => ServiceProvider::defaultProviders()->merge([
        // Tilføj dine egne providers her, hvis du får brug for det.
        // App\Providers\AppServiceProvider::class,
    ])->toArray(),

    'aliases' => Facade::defaultAliases()->merge([
        // Evt. egne aliaser her.
    ])->toArray(),
];
