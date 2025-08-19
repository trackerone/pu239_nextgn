<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\View\ViewServiceProvider;
use Illuminate\Filesystem\FilesystemServiceProvider;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withProviders([
        FilesystemServiceProvider::class,
        ViewServiceProvider::class,
    ])
    ->withMiddleware(function (Middleware $middleware) {
        // ...
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // behold gerne din nuværende, men ingen ekstra response()-logik her
    })
    ->create();
