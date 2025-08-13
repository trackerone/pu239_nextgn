<?php
// tools/fix-composer.php
// Web-only safe fixer for composer.json
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

$stripIlluminate = function(array &$section) use (&$changed) {
    if (!is_array($section)) return;
    foreach (array_keys($section) as $pkg) {
        if (str_starts_with($pkg, 'illuminate/')) {
            unset($section[$pkg]);
            $changed = true;
        }
    }
};

if (isset($json['require'])) $stripIlluminate($json['require']);
if (isset($json['require-dev'])) $stripIlluminate($json['require-dev']);

if (!isset($json['require'])) $json['require'] = [];
if (!isset($json['require']['laravel/framework'])) {
    $json['require']['laravel/framework'] = '^11.0';
    $changed = true;
} else {
    $current = $json['require']['laravel/framework'];
    if (!preg_match('/(^|\s)(\^|~)?11(\.|$)/', $current)) {
        $json['require']['laravel/framework'] = '^11.0';
        $changed = true;
    }
}

if (!isset($json['conflict'])) $json['conflict'] = [];
if (!isset($json['conflict']['illuminate/*']) || $json['conflict']['illuminate/*'] !== '>=12.0') {
    $json['conflict']['illuminate/*'] = '>=12.0';
    $changed = true;
}

if ($changed) {
    file_put_contents($file, json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL);
    echo "composer.json updated.\n";
} else {
    echo "composer.json already OK.\n";
}
