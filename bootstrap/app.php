<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

$app = Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        //
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // Fallback så vi ikke forsøger at bruge view ved fejl,
        // hvis view ikke skulle være registreret endnu:
        $exceptions->render(function (\Symfony\Component\HttpKernel\Exception\HttpExceptionInterface $e, $request) {
            return response(
                'HTTP '.$e->getStatusCode().' - '.$e->getMessage(),
                $e->getStatusCode()
            );
        });
    })
    ->create();

// 🔽 TILFØJ DISSE 2 LINJER:
$app->register(\Illuminate\View\ViewServiceProvider::class);

return $app;
