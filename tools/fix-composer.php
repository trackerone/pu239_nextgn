<?php
// tools/fix-composer.php (v3)
// - Remove direct illuminate/* from require + require-dev
// - Ensure laravel/framework ^11.0
// - Remove invalid conflict wildcard entries like "illuminate/*" if present
// - Idempotent: safe to run multiple times

$file = __DIR__ . '/../composer.json';
if (!file_exists($file)) {
    fwrite(STDERR, "composer.json not found at {$file}\n");
    exit(1);
}
$json = json_decode(file_get_contents($file), true);
if (!is_array($json)) {
    fwrite(STDERR, "Failed to parse composer.json\n");
    exit(1);
}
$changed = false;

$stripIlluminate = function(array &$section) use (&$changed) {
    if (!is_array($section)) return;
    foreach (array_keys($section) as $pkg) {
        if (strpos($pkg, 'illuminate/') === 0) {
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
    $current = (string)$json['require']['laravel/framework'];
    if (!preg_match('/(^|\s)(\^|~)?11(\.|$)/', $current)) {
        $json['require']['laravel/framework'] = '^11.0';
        $changed = true;
    }
}

// Clean up invalid conflict wildcard if present
if (isset($json['conflict']) && is_array($json['conflict'])) {
    if (array_key_exists('illuminate/*', $json['conflict'])) {
        unset($json['conflict']['illuminate/*']);
        $changed = true;
    }
    // If conflict becomes empty, remove it
    if (empty($json['conflict'])) {
        unset($json['conflict']);
        $changed = true;
    }
}

if ($changed) {
    file_put_contents($file, json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL);
    echo "composer.json updated.\n";
} else {
    echo "composer.json already OK.\n";
}
