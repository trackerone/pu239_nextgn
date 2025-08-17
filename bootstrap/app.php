<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\View\ViewServiceProvider;

return Application::configure(basePath: dirname(__DIR__))
    // Registrér View-service (giver container-bindingen "view")
    ->withProviders([
        ViewServiceProvider::class,
    ])
    // Tænd facader (så Facade::... virker, inkl. View::...)
    ->withFacades()
    // Routing (tilpas stierne hvis du ikke har api/console)
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // evt. global middleware
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // evt. exception-håndtering
    })
    ->create();
