<?php

use Illuminate\Support\Facades\Route;
use Modules\Sales\Http\Controllers\SalesController;

Route::prefix('sales')->group(function () {
    Route::get('/', [SalesController::class,'index']);
    Route::get('/{id}', [SalesController::class,'show']);
    Route::post('/create', [SalesController::class,'store']);
    Route::post('/{id}/refund', [SalesController::class,'refund']);
    Route::get('/reports/daily', [SalesController::class,'dailyReport']);
    Route::get('/reports/monthly', [SalesController::class,'monthlyReport']);
    Route::get('/reports/top-products', [SalesController::class,'topProducts']);
});
