<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome'); // kræver resources/views/welcome.blade.php
});
