<?php

namespace Modules\RBAC\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;

class RbacController extends Controller
{
    public function listPermissions()
    {
        $perms = DB::select("SELECT * FROM usr_permissions ORDER BY id");
        return response()->json(['status'=>'success','data'=>$perms]);
    }

    public function createPermission(Request $request)
    {
        $request->validate(['name'=>'required|string','code'=>'required|string']);
        DB::insert("INSERT INTO usr_permissions (name, code, description, created_at) VALUES (?, ?, ?, NOW())", [$request->name, $request->code, $request->description ?? null]);
        return response()->json(['status'=>'success','message'=>'Permission created']);
    }

    public function assignPermissionToRole(Request $request)
    {
        $request->validate(['role_id'=>'required|integer','permission_id'=>'required|integer']);
        DB::insert("INSERT INTO usr_permission_role (permission_id, role_id, assigned_at) VALUES (?, ?, NOW()) ON CONFLICT DO NOTHING", [$request->permission_id, $request->role_id]);
        return response()->json(['status'=>'success','message'=>'Assigned']);
    }

    public function listRoles()
    {
        $roles = DB::select("SELECT * FROM usr_roles ORDER BY id");
        return response()->json(['status'=>'success','data'=>$roles]);
    }

    public function createRole(Request $request)
    {
        $request->validate(['name'=>'required|string']);
        DB::insert("INSERT INTO usr_roles (name, description, is_default, created_at) VALUES (?, ?, FALSE, NOW())", [$request->name, $request->description ?? null]);
        return response()->json(['status'=>'success','message'=>'Role created']);
    }

    public function listNavigationItems(Request $request)
{
    // Optional: filter by level, type, or enabled status
    $level = $request->query('level');
    $navigation_type_id = $request->query('navigation_type_id');

    $query = "SELECT id, name, description, nav_routerlink AS route, icons_cls AS icon, 
                     has_initiateapplication_option, parent_id, level
              FROM wf_navigation_items
              WHERE is_enabled = TRUE";

    $bindings = [];

    if ($level) {
        $query .= " AND level = ?";
        $bindings[] = $level;
    }

    if ($navigation_type_id) {
        $query .= " AND navigation_type_id = ?";
        $bindings[] = $navigation_type_id;
    }

    $query .= " ORDER BY order_no, description";

    $items = DB::select($query, $bindings);

    return response()->json([
        'status' => 'success',
        'data' => $items
    ]);
}

}
