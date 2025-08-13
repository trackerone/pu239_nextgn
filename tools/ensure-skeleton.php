    <?php
    // tools/ensure-skeleton.php (from v9)
    function mkdir_p($dir) { if (!is_dir($dir)) mkdir($dir, 0777, true); }
    $root = getcwd();
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

    $bootstrapFile = $root . '/bootstrap/app.php';
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
            })
            ->withExceptions(function (Exceptions $exceptions) {
            })->create();
        PHP;
        $appPhp = str_replace(['%WEB%', '%CONSOLE%'], [$routesWeb, $routesConsole], $appPhp);
        file_put_contents($bootstrapFile, $appPhp);
        echo "[ensure] Created bootstrap/app.php
";
    } else {
        echo "[ensure] bootstrap/app.php already exists
";
    }

    $publicIndex = $root . '/public/index.php';
    if (!file_exists($publicIndex)) {
        mkdir_p($root . '/public');
        $indexPhp = <<<'PHP'
        <?php
        define('LARAVEL_START', microtime(true));
        require __DIR__.'/../vendor/autoload.php';
        $app = require_once __DIR__.'/../bootstrap/app.php';
        $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
        $response = $kernel->handle($request = Illuminate\Http\Request::capture())->send();
        $kernel->terminate($request, $response);
        PHP;
        file_put_contents($publicIndex, $indexPhp);
        echo "[ensure] Created public/index.php
";
    } else {
        echo "[ensure] public/index.php already exists
";
    }
    echo "[ensure] Writable dirs ensured
";
