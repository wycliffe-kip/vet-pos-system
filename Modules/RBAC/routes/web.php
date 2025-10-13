<?php

use Illuminate\Support\Facades\Route;
use Modules\RBAC\Http\Controllers\RBACController;

Route::middleware(['auth', 'verified'])->group(function () {
    Route::resource('rbacs', RBACController::class)->names('rbac');
});
