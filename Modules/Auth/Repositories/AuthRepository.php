<?php

namespace Modules\Auth\Repositories;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Exception;

class AuthRepository
{
    public function createUser(array $data)
    {
        return DB::transaction(function() use ($data) {
            $hashed = Hash::make($data['password']);
            $user = DB::selectOne(
                "INSERT INTO usr_users (name, email, password, is_enabled, created_at, phone_number) 
                VALUES (?, ?, ?, TRUE, NOW(), ?) RETURNING id",
                [$data['name'], $data['email'], $hashed]
            );
            if (!$user) throw new Exception('Failed to create user');

            $userId = $user->id;

            DB::insert(
                "INSERT INTO usr_users_information (user_id, phone_number, address, gender, dob, created_at) 
                VALUES (?, ?, ?, ?, ?, NOW())",
                [
                    $userId,
                    $data['phone_number'] ?? null,
                    $data['address'] ?? null,
                    $data['gender'] ?? null,
                    $data['dob'] ?? null
                ]
            );

            if (!empty($data['role_id'])) {
                DB::insert(
                    "INSERT INTO usr_user_roles (user_id, role_id, assigned_at) VALUES (?, ?, NOW())",
                    [$userId, $data['role_id']]
                );
            }

            return $this->getUserById($userId);
        });
    }

    public function getUserByEmail(string $email)
    {
        $u = DB::selectOne("SELECT * FROM usr_users WHERE email = ? LIMIT 1", [$email]);
        return $u ? (array)$u : null;
    }

    public function getUserById(int $id)
    {
        $u = DB::selectOne("SELECT id, name, email, is_enabled, created_at FROM usr_users WHERE id = ? LIMIT 1", [$id]);
        if (!$u) return null;

        $info = DB::selectOne("SELECT phone_number, address, gender, dob, profile_photo FROM usr_users_information WHERE user_id = ? LIMIT 1", [$id]);
        $roles = DB::select("SELECT r.id, r.name FROM usr_roles r JOIN usr_user_roles ur ON ur.role_id = r.id WHERE ur.user_id = ?", [$id]);
        $permissions = DB::select("
            SELECT p.code FROM usr_permissions p
            JOIN usr_permission_role pr ON pr.permission_id = p.id
            JOIN usr_user_roles ur ON ur.role_id = pr.role_id
            WHERE ur.user_id = ?", [$id]);

        return [
            'user' => (array)$u,
            'information' => $info ? (array)$info : null,
            'roles' => array_map(fn($r)=> (array)$r, $roles),
            'permissions' => array_map(fn($p)=> $p->code, $permissions)
        ];
    }

    public function verifyCredentials(string $email, string $password)
    {
        $u = $this->getUserByEmail($email);
        if (!$u || !Hash::check($password, $u['password']) || !$u['is_enabled']) return null;
        return $u;
    }

    public function createTokenForUser(int $userId)
    {
        $token = base64_encode(Str::random(48));
        DB::update("UPDATE usr_users SET remember_token = ?, updated_at = NOW() WHERE id = ?", [$token, $userId]);
        return $token;
    }

    public function revokeToken(string $token)
    {
        DB::update("UPDATE usr_users SET remember_token = NULL WHERE remember_token = ?", [$token]);
    }

    public function getUserByToken(string $token)
    {
        $u = DB::selectOne("SELECT * FROM usr_users WHERE remember_token = ? LIMIT 1", [$token]);
        if (!$u) return null;
        return $this->getUserById($u->id);
    }

    public function listUsers()
    {
        $rows = DB::select("
            SELECT u.id, u.name, u.email, u.is_enabled, i.phone_number, r.name as role
            FROM usr_users u
            LEFT JOIN usr_users_information i ON i.user_id = u.id
            LEFT JOIN usr_user_roles ur ON ur.user_id = u.id
            LEFT JOIN usr_roles r ON r.id = ur.role_id
            ORDER BY u.id DESC
        ");
        return array_map(fn($r)=>(array)$r, $rows);
    }

    // public function updateUser(int $id, array $data)
    // {
    //     return DB::transaction(function() use ($id, $data) {
    //         DB::update("UPDATE usr_users SET name = ?, email = ?, is_enabled = ?, updated_at = NOW() WHERE id = ?", [
    //             $data['name'] ?? null,
    //             $data['email'] ?? null,
    //             $data['is_enabled'] ?? true,
    //             $id
    //         ]);

    //         DB::update("UPDATE usr_users_information SET phone_number = ?, address = ?, gender = ?, dob = ?, updated_at = NOW() WHERE user_id = ?", [
    //             $data['phone_number'] ?? null,
    //             $data['address'] ?? null,
    //             $data['gender'] ?? null,
    //             $data['dob'] ?? null,
    //             $id
    //         ]);

    //         if (isset($data['role_id'])) {
    //             DB::delete("DELETE FROM usr_user_roles WHERE user_id = ?", [$id]);
    //             DB::insert("INSERT INTO usr_user_roles (user_id, role_id, assigned_at) VALUES (?, ?, NOW())", [$id, $data['role_id']]);
    //         }

    //         return $this->getUserById($id);
    //     });
    // }
    public function updateUser(int $id, array $data)
{
    return DB::transaction(function () use ($id, $data) {

        // ✅ Update main user info
        DB::table('usr_users')
            ->where('id', $id)
            ->update([
                'name' => $data['name'] ?? null,
                'email' => $data['email'] ?? null,
                'phone_number' => $data['phone_number'] ?? null,
                'is_enabled' => $data['is_enabled'] ?? true,
                'updated_at' => now(),
            ]);

        // ✅ Handle role update
        if (!empty($data['role_id'])) {
            DB::table('usr_user_roles')
                ->updateOrInsert(
                    ['user_id' => $id],
                    ['role_id' => $data['role_id'], 'assigned_at' => now()]
                );
        }

        // ✅ Handle user information (phone, gender, etc.)
        DB::table('usr_users_information')
            ->updateOrInsert(
                ['user_id' => $id],
                [
                    'phone_number' => $data['phone_number'] ?? null,
                    'address' => $data['address'] ?? null,
                    'gender' => $data['gender'] ?? null,
                    'dob' => $data['dob'] ?? null,
                    'updated_at' => now(),
                ]
            );

        // ✅ Return the updated user
        return DB::selectOne("
            SELECT 
                u.id, u.name, u.email, u.is_enabled, u.phone_number,
                r.name AS role_name,
                ui.phone_number, ui.address, ui.gender, ui.dob
            FROM usr_users u
            LEFT JOIN usr_user_roles ur ON u.id = ur.user_id
            LEFT JOIN usr_roles r ON r.id = ur.role_id
            LEFT JOIN usr_users_information ui ON ui.user_id = u.id
            WHERE u.id = ?
        ", [$id]);
    });
}


    // Count all users
public function countUsers()
{
    $row = DB::selectOne("SELECT COUNT(*) as count FROM usr_users");
    return $row->count ?? 0;
}

// Count active users
public function countActiveUsers()
{
    $row = DB::selectOne("SELECT COUNT(*) as count FROM usr_users WHERE is_enabled = TRUE");
    return $row->count ?? 0;
}

// List roles
public function listRoles()
{
    $rows = DB::select("SELECT id, name FROM usr_roles ORDER BY id ASC");
    return array_map(fn($r) => (array)$r, $rows);
}
// Latest users
public function latestUsers(int $limit = 5)
{
    $rows = DB::select("
        SELECT id, name, email, is_enabled, created_at 
        FROM usr_users
        ORDER BY created_at DESC
        LIMIT ?
    ", [$limit]);

    return array_map(fn($r) => (array)$r, $rows);
}

// Recent logins (assuming usr_user_logins table exists)
public function recentLogins(int $limit = 5)
{
    $rows = DB::select("
        SELECT u.id as user_id, u.name, l.logged_in_at, l.logged_out_at, l.ip_address
        FROM usr_user_logins l
        JOIN usr_users u ON u.id = l.user_id
        ORDER BY l.logged_in_at DESC
        LIMIT ?
    ", [$limit]);

    return array_map(fn($r) => (array)$r, $rows);
}

public function recentFailedLogins(int $limit = 5)
{
    $rows = DB::select("
        SELECT email, ip_address, reason, attempted_at 
        FROM usr_failed_logins
        ORDER BY attempted_at DESC
        LIMIT ?
    ", [$limit]);

    return array_map(fn($r) => (array)$r, $rows);
}

    public function deleteUser(int $id)
    {
        DB::delete("DELETE FROM usr_users WHERE id = ?", [$id]);
    }
}
