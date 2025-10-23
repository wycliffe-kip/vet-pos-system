<?php

// use Illuminate\Support\Facades\Route;
// use Modules\RBAC\Http\Controllers\RBACController;

// Route::prefix('rbac')->group(function () {
//     Route::get('/permissions', [RbacController::class,'listPermissions']);
//     Route::post('/permissions', [RbacController::class,'createPermission']);
//     Route::post('/permissions/assign', [RbacController::class,'assignPermissionToRole']);
//     Route::get('/roles', [RbacController::class,'listRoles']);
//     Route::get('/navigation-items', [RbacController::class,'listNavigationItems']);
//     Route::post('/roles', [RbacController::class,'createRole']);
// });


use Illuminate\Support\Facades\Route;
use Modules\RBAC\Http\Controllers\RbacController;

Route::prefix('rbac')->group(function () {

    /** ---------------- ROLES ---------------- */
    Route::get('/roles', [RbacController::class, 'listRoles']);
    Route::post('/roles', [RbacController::class, 'createRole']);

    /** ---------------- PERMISSIONS ---------------- */
    Route::get('/permissions', [RbacController::class, 'listPermissions']);
    Route::post('/permissions', [RbacController::class, 'createPermission']);
    Route::put('/permissions/{id}', [RbacController::class, 'updatePermission']);
    Route::delete('/permissions/{id}', [RbacController::class, 'deletePermission']);
    Route::post('/assign-permission', [RbacController::class, 'assignPermissionToRole']);

    /** ---------------- USERS ---------------- */
    Route::get('/users', [RbacController::class, 'listUsers']);
    Route::post('/users', [RbacController::class, 'createUser']);
    Route::post('/assign-role', [RbacController::class, 'assignRoleToUser']);

    /** ---------------- USER PERMISSIONS ---------------- */
    Route::get('/users/{userId}/permissions', [RbacController::class, 'getUserPermissions']);

    /** ---------------- NAVIGATION ---------------- */
    Route::get('/navigation-items', [RbacController::class, 'listNavigationItems']);
    Route::get('/users/{userId}/navigation', [RbacController::class, 'getUserNavigation']);
});
