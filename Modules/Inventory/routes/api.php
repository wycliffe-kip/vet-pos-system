<?php

use Illuminate\Support\Facades\Route;
use Modules\Inventory\Http\Controllers\InventoryController;

Route::prefix('inventory')->group(function () {

    // 📋 Metadata
    Route::get('/categories', [InventoryController::class, 'getCategories']);
    Route::get('/units', [InventoryController::class, 'getUnits']);

    // 🧱 Product CRUD
    Route::get('/', [InventoryController::class, 'getAllProductData']);
    Route::post('/saveProduct', [InventoryController::class, 'saveProduct']);
    
    // ⚠️ Reports / Lists
    Route::get('/low-stock', [InventoryController::class, 'lowStock']);
    
    // 🧾 History
    Route::get('/{id}/history', [InventoryController::class, 'stockHistory']);
    
    // 📦 Stock Management
    Route::post('/{id}/adjust-stock', [InventoryController::class, 'adjustStock']);
    // Route::post('/{id}/add-stock', [InventoryController::class, 'addNewStock']); // ✅ fixed here
    Route::post('/{id}/add-stock', [InventoryController::class, 'addNewStock']);

    // 🧱 Single Product Operations
    Route::get('/{id}', [InventoryController::class, 'show'])->where('id', '[0-9]+');
    Route::put('/{id}', [InventoryController::class, 'updateProduct']);
    Route::delete('/{id}', [InventoryController::class, 'destroy']);

    // 📦 Purchase History
    Route::get('/{id}/purchase-history', [InventoryController::class, 'purchaseHistory']);
        // Config routes
    Route::get('/config-tables', [InventoryController::class, 'getConfigTables']); // GET /inventory/config-tables
    Route::get('/load-config', [InventoryController::class, 'loadConfig']);        // GET /inventory/loadConfig
    Route::post('/saveConfig', [InventoryController::class, 'saveConfig']);       // POST /inventory/saveConfig
    Route::delete('/deleteConfig/{id}', [InventoryController::class, 'deleteConfig']); // DELETE /inventory/deleteConfig/:id
});
