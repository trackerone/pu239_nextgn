<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function ($middleware) {
        //
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // Midlertidigt: print fejl i klartekst i stedet for et view
        $exceptions->render(function (Throwable $e, Request $request) {
            return response(
                "ERR: {$e->getMessage()}\n{$e->getFile()}:{$e->getLine()}",
                500,
                ['Content-Type' => 'text/plain']
            );
        });
    })
    ->create();
