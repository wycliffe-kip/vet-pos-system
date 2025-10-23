<?php

use Illuminate\Support\Facades\Route;
use Modules\RBAC\Http\Controllers\RbacController;

Route::middleware(['auth', 'verified'])->group(function () {
    Route::resource('rbacs', RBACController::class)->names('rbac');
});
