<?php

use Illuminate\Support\Facades\Route;
use Modules\Auth\Http\Controllers\AuthController;

Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class,'register']);
    Route::post('/login', [AuthController::class,'login']);

    // Routes that require authentication will check token inside controller
    Route::get('/me', [AuthController::class,'me']);
    Route::post('/logout', [AuthController::class,'logout']);
    Route::get('/users', [AuthController::class,'index']);
    Route::put('/users/{id}', [AuthController::class,'update']);
    Route::delete('/users/{id}', [AuthController::class,'destroy']);
    Route::get('/dashboard', [AuthController::class, 'dashboard']);
});
