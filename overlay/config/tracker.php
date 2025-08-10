<?php

return [
    // Modes: 'embedded' (handle announce/scrape in this app) or 'external' (redirect)
    'mode' => env('TRACKER_MODE', 'embedded'),
    // External announce URL, e.g. 'udp://tracker.example.com:6969/announce' or 'https://tracker.example.com/announce'
    'external_announce' => env('EXTERNAL_ANNOUNCE_URL', ''),
];
