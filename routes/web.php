<?php

use Illuminate\Support\Facades\Route;

// ---------------- Register Module Web Routes ----------------
// Register module web routes first (Auth, Inventory, RBAC, Sales)
require base_path('Modules/Auth/routes/web.php');
require base_path('Modules/Inventory/routes/web.php');
require base_path('Modules/RBAC/routes/web.php');
require base_path('Modules/Sales/routes/web.php');

// SPA Routing: serve Angular index.html for all non-API routes
Route::get('/{any}', function () {
    return file_get_contents(public_path('resources/index.html'));
})->where('any', '^(?!api).*$'); // Excludes /api routes
