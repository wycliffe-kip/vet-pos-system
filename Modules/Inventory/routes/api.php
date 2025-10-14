<?php

use Illuminate\Support\Facades\Route;
use Modules\Inventory\Http\Controllers\InventoryController;

Route::prefix('inventory')->group(function () {
    Route::get('/categories', [InventoryController::class, 'getCategories']);
    Route::get('/', [InventoryController::class, 'index']);
    Route::post('/', [InventoryController::class, 'store']);
    
    // 🔹 Put specific routes first
    Route::get('/low-stock', [InventoryController::class, 'lowStock']);
    Route::get('/{id}/history', [InventoryController::class, 'stockHistory']);
    
    // Then the general /{id} route
    Route::get('/{id}', [InventoryController::class, 'show']);
    Route::put('/{id}', [InventoryController::class, 'update']);
    Route::delete('/{id}', [InventoryController::class, 'destroy']);

    // Stock management
    Route::post('/{id}/adjust-stock', [InventoryController::class, 'adjustStock']);
    Route::post('/inventory/{id}/add-stock', [InventoryController::class, 'addNewStock']);

});


