<?php

use Illuminate\Support\Facades\Route;
use Modules\Sales\Http\Controllers\SalesController;

// Route::prefix('sales')->group(function () {
//     Route::get('/', [SalesController::class,'index']);
//     Route::get('/{id}', [SalesController::class,'show']);
//     Route::post('/create', [SalesController::class,'store']);
//     Route::post('/{id}/refund', [SalesController::class,'refund']);
//     Route::get('/reports/daily', [SalesController::class,'dailyReport']);
//     Route::get('/reports/monthly', [SalesController::class,'monthlyReport']);
//     Route::get('/reports/top-products', [SalesController::class,'topProducts']);
// });


// Route::prefix('sales')->group(function () {
//     Route::get('/', [SalesController::class, 'index']); // list all
//     Route::get('/{id}', [SalesController::class, 'show']); // show single
//     Route::post('/', [SalesController::class, 'onCreateSale']); // create
//     Route::delete('/{id}/refund', [SalesController::class, 'refund']); // refund
//     Route::get('/reports/daily', [SalesController::class, 'dailyReport']);
//     Route::get('/reports/monthly', [SalesController::class, 'monthlyReport']);
//     Route::get('/reports/top-products', [SalesController::class, 'topProducts']);
// });



Route::prefix('sales')->group(function () {
    Route::get('/', [SalesController::class, 'index']);
    Route::get('/{id}', [SalesController::class, 'show']);
    Route::get('/details/{id}', [SalesController::class, 'getSaleDetails']); 
    Route::get('/{id}/items', [SalesController::class, 'getSaleDetails']); 
    Route::post('/onCreateSale', [SalesController::class, 'onCreateSale']);
    Route::delete('/{id}/refund', [SalesController::class, 'refund']);
    Route::get('/reports/daily', [SalesController::class, 'dailyReport']);
    Route::get('/reports/monthly', [SalesController::class, 'monthlyReport']);
    Route::get('/reports/top-products', [SalesController::class, 'topProducts']);
    Route::get('/reports/dashboard', [SalesController::class, 'dashboardReport']);
});
// Route::prefix('sales')->middleware('auth:sanctum')->group(function () {
//     Route::get('/', [SalesController::class, 'index']);
//     Route::get('/{id}', [SalesController::class, 'show']);
//     Route::get('/details/{id}', [SalesController::class, 'getSaleDetails']); 
//     Route::get('/{id}/items', [SalesController::class, 'getSaleDetails']); 
//     Route::post('/', [SalesController::class, 'onCreateSale']);
//     Route::delete('/{id}/refund', [SalesController::class, 'refund']);
//     Route::get('/reports/daily', [SalesController::class, 'dailyReport']);
//     Route::get('/reports/monthly', [SalesController::class, 'monthlyReport']);
//     Route::get('/reports/top-products', [SalesController::class, 'topProducts']);
//     Route::get('/reports/dashboard', [SalesController::class, 'dashboardReport']);
// });
