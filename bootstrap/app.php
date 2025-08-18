<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Contracts\Container\BindingResolutionException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        api: __DIR__ . '/../routes/api.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // tilføj evt. middleware her
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // Hvis containeren ikke kan binde en klasse (fx "view"),
        // så svar med enkel tekst, ikke Blade-view:
        $exceptions->render(function (BindingResolutionException $e, $request) {
            return new \Illuminate\Http\Response(
                'ERR: ' . $e->getMessage(),
                500,
                ['Content-Type' => 'text/plain']
            );
        });
    })
    ->create();
