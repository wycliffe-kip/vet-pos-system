<?php

use Illuminate\Support\Facades\Route;
use Modules\RBAC\Http\Controllers\RBACController;

Route::prefix('rbac')->group(function () {
    Route::get('/permissions', [RbacController::class,'listPermissions']);
    Route::post('/permissions', [RbacController::class,'createPermission']);
    Route::post('/permissions/assign', [RbacController::class,'assignPermissionToRole']);
    Route::get('/roles', [RbacController::class,'listRoles']);
    Route::get('/navigation-items', [RbacController::class,'listNavigationItems']);
    Route::post('/roles', [RbacController::class,'createRole']);
});
