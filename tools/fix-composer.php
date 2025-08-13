<?php
/**
 * fix-composer.php
 *
 * Purpose:
 *  - Remove direct illuminate/* packages (they conflict with laravel/framework which replaces them)
 *  - Ensure laravel/framework ^11.0 is required
 *  - Add a conflict rule to prevent illuminate/* 12.x when using Laravel 11
 *  - Preserve all other existing dependencies
 *
 * Usage:
 *   php tools/fix-composer.php
 *
 * Then review the changes (git diff), and run:
 *   composer update laravel/framework --with-all-dependencies
 *   composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader
 */
$file = __DIR__ . '/../composer.json';
if (!file_exists($file)) {
    fwrite(STDERR, "composer.json not found at {$file}\n");
    exit(1);
}
$json = json_decode(file_get_contents($file), true);
if ($json === null) {
    fwrite(STDERR, "Failed to parse composer.json\n");
    exit(1);
}

$changed = false;

// Helper to strip illuminate/* entries from a section
$stripIlluminate = function(array &$section, string $sectionName) use (&$changed) {
    if (!is_array($section)) return;
    foreach (array_keys($section) as $pkg) {
        if (str_starts_with($pkg, 'illuminate/')) {
            unset($section[$pkg]);
            $changed = true;
        }
    }
};

// Remove illuminate/* from require and require-dev (laravel/framework is not illuminate/* so it's safe)
if (isset($json['require']) && is_array($json['require'])) {
    $stripIlluminate($json['require'], 'require');
}
if (isset($json['require-dev']) && is_array($json['require-dev'])) {
    $stripIlluminate($json['require-dev'], 'require-dev');
}

// Ensure laravel/framework ^11.0 is present
if (!isset($json['require'])) $json['require'] = [];
if (!isset($json['require']['laravel/framework'])) {
    $json['require']['laravel/framework'] = '^11.0';
    $changed = true;
} else {
    // Normalize to ^11 if user had a different range (we don't override if already ^11)
    $current = $json['require']['laravel/framework'];
    if (!preg_match('/(^|\s)(\^|~)?11(\.|$)/', $current)) {
        $json['require']['laravel/framework'] = '^11.0';
        $changed = true;
    }
}

// Add/merge a conflict rule to avoid illuminate/* 12.x (common cause of composer conflicts)
if (!isset($json['conflict'])) $json['conflict'] = [];
if (!isset($json['conflict']['illuminate/*']) || $json['conflict']['illuminate/*'] !== '>=12.0') {
    $json['conflict']['illuminate/*'] = '>=12.0';
    $changed = true;
}

if ($changed) {
    // Pretty print JSON
    $new = json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL;
    file_put_contents($file, $new);
    echo "composer.json updated. Please review changes and run composer update.\n";
    exit(0);
} else {
    echo "No changes needed. composer.json already compatible.\n";
    exit(0);
}
