<?php

use Illuminate\Support\Facades\Route;
use Modules\Inventory\Http\Controllers\InventoryController;

Route::prefix('inventory')->group(function () {
    Route::get('/', [InventoryController::class, 'index']);
    Route::post('/', [InventoryController::class, 'store']);
    Route::get('/{id}', [InventoryController::class, 'show']);
    Route::put('/{id}', [InventoryController::class, 'update']);
    Route::delete('/{id}', [InventoryController::class, 'destroy']);

    // Stock management
    Route::post('/{id}/adjust-stock', [InventoryController::class, 'adjustStock']);
    Route::get('/low-stock', [InventoryController::class, 'lowStock']);
    Route::get('/{id}/history', [InventoryController::class, 'stockHistory']);
});


