<?php

namespace Modules\RBAC\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Exception;

class RbacController extends Controller
{
    /* ==================== ROLES ==================== */

    public function listRoles()
    {
        $roles = DB::select('SELECT id, name, description, is_default FROM usr_roles ORDER BY id');
        return response()->json(['status' => 'success', 'data' => array_map(fn($r) => (array)$r, $roles)]);
    }

    public function createRole(Request $request)
    {
        $v = Validator::make($request->all(), [
            'name' => 'required|string|unique:usr_roles,name',
            'description' => 'nullable|string',
            'is_default' => 'nullable|boolean'
        ]);
        if ($v->fails()) return response()->json(['status' => 'error', 'errors' => $v->errors()], 422);

        try {
            DB::transaction(function () use ($request) {
                DB::insert(
                    'INSERT INTO usr_roles (name, description, is_default, created_at) VALUES (?, ?, ?, NOW())',
                    [$request->name, $request->description ?? null, $request->is_default ? true : false]
                );
            });
            return response()->json(['status' => 'success', 'message' => 'Role created']);
        } catch (Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function deleteRole($id)
    {
        try {
            DB::transaction(function () use ($id) {
                DB::delete('DELETE FROM usr_permission_roles WHERE role_id = ?', [$id]);
                DB::delete('DELETE FROM usr_user_roles WHERE role_id = ?', [$id]);
                DB::delete('DELETE FROM usr_roles WHERE id = ?', [$id]);
            });
            return response()->json(['status' => 'success', 'message' => 'Role deleted']);
        } catch (Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /* ==================== PERMISSIONS ==================== */

    public function listPermissions()
    {
        $permissions = DB::select("
        SELECT 
            p.id,
            p.name,
            p.code,
            p.description,
            p.navigation_item_id,
            n.name AS navigation_name,        -- Linked Navigation name
            n.nav_routerlink AS navigation_route, -- Optional: useful if you want to show or debug routes
            n.icons_cls AS navigation_icon,   -- Optional: icon for display or debugging
            p.created_at,
            p.updated_at
        FROM usr_permissions p
        LEFT JOIN wf_navigation_items n ON n.id = p.navigation_item_id
        ORDER BY p.id
    ");

        return response()->json([
            'status' => 'success',
            'data' => array_map(fn($p) => (array)$p, $permissions)
        ]);
    }


    public function createPermission(Request $request)
    {
        $v = Validator::make($request->all(), [
            'name' => 'required|string|unique:usr_permissions,name',
            'code' => 'required|string|unique:usr_permissions,code',
            'description' => 'nullable|string',
            'navigation_item_id' => 'nullable|integer|exists:wf_navigation_items,id'
        ]);
        if ($v->fails()) return response()->json(['status' => 'error', 'errors' => $v->errors()], 422);

        try {
            DB::transaction(function () use ($request) {
                DB::insert(
                    'INSERT INTO usr_permissions (name, code, description, navigation_item_id, created_at)
                     VALUES (?, ?, ?, ?, NOW())',
                    [$request->name, $request->code, $request->description ?? null, $request->navigation_item_id ?? null]
                );
            });
            return response()->json(['status' => 'success', 'message' => 'Permission created']);
        } catch (Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function assignPermissionToRole(Request $request)
    {
        $v = Validator::make($request->all(), [
            'role_id' => 'required|integer|exists:usr_roles,id',
            'permission_id' => 'required|integer|exists:usr_permissions,id'
        ]);
        if ($v->fails()) return response()->json(['status' => 'error', 'errors' => $v->errors()], 422);

        try {
            DB::transaction(function () use ($request) {
                DB::insert(
                    'INSERT INTO usr_permission_roles (permission_id, role_id, assigned_at)
                     VALUES (?, ?, NOW()) ON CONFLICT DO NOTHING',
                    [$request->permission_id, $request->role_id]
                );
            });
            return response()->json(['status' => 'success', 'message' => 'Permission assigned to role']);
        } catch (Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function revokePermissionFromRole(Request $request)
    {
        $v = Validator::make($request->all(), [
            'role_id' => 'required|integer|exists:usr_roles,id',
            'permission_id' => 'required|integer|exists:usr_permissions,id'
        ]);
        if ($v->fails()) return response()->json(['status' => 'error', 'errors' => $v->errors()], 422);

        try {
            DB::transaction(function () use ($request) {
                DB::delete('DELETE FROM usr_permission_roles WHERE role_id = ? AND permission_id = ?', [
                    $request->role_id,
                    $request->permission_id
                ]);
            });
            return response()->json(['status' => 'success', 'message' => 'Permission revoked from role']);
        } catch (Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function listUsers()
    {
        $users = DB::select("
        SELECT 
            u.id,
            u.name,
            u.email,
            u.is_enabled,
            u.phone_number,
            r.name AS role_name
        FROM usr_users u
        LEFT JOIN usr_user_roles ur ON u.id = ur.user_id
        LEFT JOIN usr_roles r ON r.id = ur.role_id
        ORDER BY u.id ASC
    ");

        return response()->json([
            'status' => 'success',
            'data' => array_map(fn($u) => (array)$u, $users)
        ]);
    }

    public function createUser(Request $request)
    {
        $v = Validator::make($request->all(), [
            'name' => 'required|string|max:150',
            'email' => 'required|email|unique:usr_users,email',
            'password' => 'required|string|min:6',
            'role_id' => 'nullable|integer|exists:usr_roles,id',
            'phone_number' => 'nullable|string|max:50',
            'address' => 'nullable|string|max:255',
            'gender' => 'nullable|string|max:10',
            'dob' => 'nullable|date',
            'profile_photo' => 'nullable|string|max:255',
        ]);

        if ($v->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $v->errors()
            ], 422);
        }

        try {
            $userId = null;

            DB::transaction(function () use ($request, &$userId) {

                // 1️⃣ Create user
                $userId = DB::table('usr_users')->insertGetId([
                    'name' => $request->name,
                    'email' => $request->email,
                    'password' => Hash::make($request->password),
                    'is_enabled' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                // 2️⃣ Insert into usr_users_information (linked by user_id)
                DB::table('usr_users_information')->insert([
                    'user_id' => $userId,
                    'phone_number' => $request->phone_number,
                    'address' => $request->address,
                    'gender' => $request->gender,
                    'dob' => $request->dob,
                    'profile_photo' => $request->profile_photo,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                // 3️⃣ Assign role if provided
                if ($request->role_id) {
                    DB::insert(
                        'INSERT INTO usr_user_roles (user_id, role_id, assigned_at) VALUES (?, ?, NOW())',
                        [$userId, $request->role_id]
                    );
                }
            });

            return response()->json([
                'status' => 'success',
                'message' => 'User created successfully',
                'user_id' => $userId
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    public function assignRoleToUser(Request $request)
    {
        $v = Validator::make($request->all(), [
            'user_id' => 'required|integer|exists:usr_users,id',
            'role_id' => 'required|integer|exists:usr_roles,id'
        ]);
        if ($v->fails()) return response()->json(['status' => 'error', 'errors' => $v->errors()], 422);

        try {
            DB::transaction(function () use ($request) {
                DB::insert(
                    'INSERT INTO usr_user_roles (user_id, role_id, assigned_at) VALUES (?, ?, NOW()) ON CONFLICT DO NOTHING',
                    [$request->user_id, $request->role_id]
                );
            });
            return response()->json(['status' => 'success', 'message' => 'Role assigned to user']);
        } catch (Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function revokeRoleFromUser(Request $request)
    {
        $v = Validator::make($request->all(), [
            'user_id' => 'required|integer|exists:usr_users,id',
            'role_id' => 'required|integer|exists:usr_roles,id'
        ]);
        if ($v->fails()) return response()->json(['status' => 'error', 'errors' => $v->errors()], 422);

        try {
            DB::transaction(function () use ($request) {
                DB::delete('DELETE FROM usr_user_roles WHERE user_id = ? AND role_id = ?', [$request->user_id, $request->role_id]);
            });
            return response()->json(['status' => 'success', 'message' => 'Role revoked from user']);
        } catch (Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getUserPermissions($userId)
    {
        $perms = DB::select("
            SELECT DISTINCT p.id, p.name, p.code, p.description, p.navigation_item_id
            FROM usr_permissions p
            INNER JOIN usr_permission_roles pr ON p.id = pr.permission_id
            INNER JOIN usr_user_roles ur ON ur.role_id = pr.role_id
            WHERE ur.user_id = ?
        ", [$userId]);

        return response()->json(['status' => 'success', 'data' => array_map(fn($p) => (array)$p, $perms)]);
    }

    public function updatePermission(Request $request, $id)
    {
        $v = Validator::make($request->all(), [
            'name' => 'required|string|unique:usr_permissions,name,' . $id,
            'code' => 'required|string|unique:usr_permissions,code,' . $id,
            'description' => 'nullable|string',
            'navigation_item_id' => 'nullable|integer|exists:wf_navigation_items,id'
        ]);
        if ($v->fails()) {
            return response()->json(['status' => 'error', 'errors' => $v->errors()], 422);
        }

        try {
            DB::transaction(function () use ($request, $id) {
                DB::update(
                    'UPDATE usr_permissions SET name = ?, code = ?, description = ?, navigation_item_id = ?, updated_at = NOW() WHERE id = ?',
                    [$request->name, $request->code, $request->description, $request->navigation_item_id, $id]
                );
            });

            return response()->json(['status' => 'success', 'message' => 'Permission updated']);
        } catch (Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function deletePermission($id)
    {
        try {
            DB::transaction(function () use ($id) {
                DB::delete('DELETE FROM usr_permission_roles WHERE permission_id = ?', [$id]);
                DB::delete('DELETE FROM usr_permissions WHERE id = ?', [$id]);
            });

            return response()->json(['status' => 'success', 'message' => 'Permission deleted']);
        } catch (Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }


    /* ==================== NAVIGATION ==================== */
public function saveNavigationItem(Request $request)
{
    // Determine if this is an update or create operation
    $isUpdate = $request->has('id') && !empty($request->id);

    // Common validation rules
    $rules = [
        'name' => 'required|string|max:255',
        'description' => 'nullable|string|max:500',
        'nav_routerlink' => 'nullable|string|max:255',
        'icons_cls' => 'nullable|string|max:100',
        'parent_id' => 'nullable|integer|exists:wf_navigation_items,id',
        'level' => 'nullable|integer|min:1',
        'order_no' => 'nullable|integer|min:0',
        'is_enabled' => 'nullable|boolean'
    ];

    if ($isUpdate) {
        $rules['id'] = 'required|integer|exists:wf_navigation_items,id';
    }

    $validator = Validator::make($request->all(), $rules);
    if ($validator->fails()) {
        return response()->json([
            'status' => 'error',
            'errors' => $validator->errors()
        ], 422);
    }

    try {
        DB::transaction(function () use ($request, $isUpdate) {
            $data = [
                'name' => $request->name,
                'description' => $request->description,
                'nav_routerlink' => $request->nav_routerlink,
                'icons_cls' => $request->icons_cls,
                'parent_id' => $request->parent_id,
                'level' => $request->level ?? 1,
                'order_no' => $request->order_no ?? 0,
                'is_enabled' => $request->is_enabled ?? true,
                'updated_at' => now(),
            ];

            if ($isUpdate) {
                // 🔁 Update existing navigation
                DB::table('wf_navigation_items')
                    ->where('id', $request->id)
                    ->update($data);
            } else {
                // ➕ Insert new navigation
                $data['created_at'] = now();
                DB::table('wf_navigation_items')->insert($data);
            }
        });

        return response()->json([
            'status' => 'success',
            'message' => $isUpdate
                ? 'Navigation item updated successfully.'
                : 'Navigation item created successfully.'
        ]);

    } catch (Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Failed to save navigation item: ' . $e->getMessage()
        ], 500);
    }
}

    public function listNavigationItems(Request $request)
    {
        $query = 'SELECT id, name, description, nav_routerlink AS route, icons_cls AS icon,
                         parent_id, level, order_no, is_enabled
                  FROM wf_navigation_items WHERE is_enabled = TRUE ORDER BY order_no';
        $items = DB::select($query);
        return response()->json(['status' => 'success', 'data' => array_map(fn($i) => (array)$i, $items)]);
    }

    public function getUserNavigation(Request $request, $userId)
    {
        // ✅ Accept one or multiple role IDs
        $roleIds = (array) $request->input('role_id');

        if (empty($roleIds)) {
            return response()->json([
                'success' => false,
                'message' => 'role_id is required'
            ], 400);
        }

        // ✅ Build query with Query Builder
        $items = DB::table('wf_navigation_items as n')
            ->join('usr_permissions as p', 'n.id', '=', 'p.navigation_item_id')
            ->join('usr_permission_role as pr', 'p.id', '=', 'pr.permission_id')
            ->join('usr_roles as r', 'r.id', '=', 'pr.role_id')
            ->whereIn('pr.role_id', $roleIds)
            ->where('n.is_enabled', true)
            ->distinct()
            ->select(
                'n.id',
                'n.name',
                'n.description',
                'n.parent_id',
                'n.order_no',
                'n.icons_cls as iconsCls',
                'n.nav_routerlink as route',
                'n.level',
                'n.is_enabled',
                'r.id as role_id',
                'r.name as role_name'
            )
            ->orderBy('n.order_no')
            ->get();

        $items = $items->map(fn($r) => (array)$r)->toArray();

        // ✅ Build hierarchical tree
        $tree = $this->buildNavigationTree($items);

        return response()->json([
            'success' => true,
            'navigation_items' => $tree,
            'role_ids' => $roleIds
        ]);
    }


    protected function buildNavigationTree(array $items)
    {
        $byId = [];
        foreach ($items as $item) {
            $item['children'] = [];
            $byId[$item['id']] = $item;
        }

        $tree = [];
        foreach ($byId as $id => $item) {
            $parentId = $item['parent_id'] ?? null;
            if ($parentId && isset($byId[$parentId])) {
                $byId[$parentId]['children'][] = &$byId[$id];
            } else {
                $tree[] = &$byId[$id];
            }
        }

        $this->sortNavigationRecursive($tree);
        return $tree;
    }

    protected function sortNavigationRecursive(array &$nodes)
    {
        usort($nodes, fn($a, $b) => ($a['order_no'] ?? 0) <=> ($b['order_no'] ?? 0));
        foreach ($nodes as &$n) if (!empty($n['children'])) $this->sortNavigationRecursive($n['children']);
    }
}
