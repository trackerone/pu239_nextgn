    <?php
    // tools/ensure-skeleton.php (v9)
    // - Creates minimal Laravel 11 bootstrap/app.php and public/index.php if missing
    // - Ensures bootstrap/cache and storage/* dirs exist and are writable
    // - Uses NOWDOC to avoid variable interpolation warnings

    function mkdir_p($dir) {
        if (!is_dir($dir)) mkdir($dir, 0777, true);
    }

    $root = getcwd();

    // 0) Ensure writable dirs
    mkdir_p($root . '/bootstrap/cache');
    mkdir_p($root . '/storage/framework/cache');
    mkdir_p($root . '/storage/framework/sessions');
    mkdir_p($root . '/storage/framework/views');
    @chmod($root . '/bootstrap/cache', 0777);
    @chmod($root . '/storage', 0777);
    @chmod($root . '/storage/framework', 0777);
    @chmod($root . '/storage/framework/cache', 0777);
    @chmod($root . '/storage/framework/sessions', 0777);
    @chmod($root . '/storage/framework/views', 0777);

    // 1) bootstrap/app.php
    $bootstrapDir = $root . '/bootstrap';
    $bootstrapFile = $bootstrapDir . '/app.php';
    if (!file_exists($bootstrapFile)) {
        $routesWeb = file_exists($root.'/routes/web.php') ? "__DIR__.'/../routes/web.php'" : 'null';
        $routesConsole = file_exists($root.'/routes/console.php') ? "__DIR__.'/../routes/console.php'" : 'null';

        $appPhp = <<<'PHP'
        <?php

        use Illuminate\Foundation\Application;
        use Illuminate\Foundation\Configuration\Exceptions;
        use Illuminate\Foundation\Configuration\Middleware;

        return Application::configure(basePath: dirname(__DIR__))
            ->withRouting(
                web: %WEB%,
                commands: %CONSOLE%,
                health: '/up',
            )
            ->withMiddleware(function (Middleware $middleware) {
                // add middleware here if needed
            })
            ->withExceptions(function (Exceptions $exceptions) {
                // customize exception handling
            })->create();
        PHP;
        // Inject route paths
        $appPhp = str_replace(['%WEB%', '%CONSOLE%'], [$routesWeb, $routesConsole], $appPhp);
        file_put_contents($bootstrapFile, $appPhp);
        echo "[ensure] Created bootstrap/app.php\n";
    } else {
        echo "[ensure] bootstrap/app.php already exists\n";
    }

    // 2) public/index.php
    $publicDir = $root . '/public';
    $publicIndex = $publicDir . '/index.php';
    if (!file_exists($publicIndex)) {
        mkdir_p($publicDir);
        $indexPhp = <<<'PHP'
        <?php

        define('LARAVEL_START', microtime(true));

        require __DIR__.'/../vendor/autoload.php';

        $app = require_once __DIR__.'/../bootstrap/app.php';

        $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

        $response = $kernel->handle(
            $request = Illuminate\Http\Request::capture()
        )->send();

        $kernel->terminate($request, $response);
        PHP;
        file_put_contents($publicIndex, $indexPhp);
        echo "[ensure] Created public/index.php\n";
    } else {
        echo "[ensure] public/index.php already exists\n";
    }

    // 3) Ensure .gitignore stubs so dirs persist if needed
    $gitignores = [
        $root . '/bootstrap/cache/.gitignore' => "*
!.gitignore
",
        $root . '/storage/framework/.gitignore' => "*
!.gitignore
",
        $root . '/storage/framework/cache/.gitignore' => "*
!.gitignore
",
        $root . '/storage/framework/sessions/.gitignore' => "*
!.gitignore
",
        $root . '/storage/framework/views/.gitignore' => "*
!.gitignore
",
    ];
    foreach ($gitignores as $file => $content) {
        if (!file_exists($file)) {
            file_put_contents($file, $content);
        }
    }

    echo "[ensure] Writable dirs ensured\n";
