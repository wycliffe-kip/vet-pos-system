<?php

namespace Modules\Auth\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Modules\Auth\Repositories\AuthRepository;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Http\Exceptions\HttpResponseException;

class AuthController extends Controller
{
    protected AuthRepository $repo;

    public function __construct(AuthRepository $repo)
    {
        $this->repo = $repo;
    }

    // Register (admin creates user)
    public function register(Request $request)
    {
        $v = Validator::make($request->all(), [
            'name'=>'required|string',
            'email'=>'required|email|unique:usr_users,email',
            'password'=>'required|min:6',
            'role_id'=>'nullable|integer',
            'phone_number'=>'nullable|string',
            'address'=>'nullable|string',
            'gender'=>'nullable|string',
            'dob'=>'nullable|date'
        ]);
        if ($v->fails()) return response()->json(['errors'=>$v->errors()], 422);

        try {
            $data = $request->only(['name','email','password','role_id','phone_number','address','gender','dob']);
            $user = $this->repo->createUser($data);
            return response()->json(['status'=>'success','data'=>$user], 201);
        } catch (Exception $e) {
            return response()->json(['status'=>'error','message'=>$e->getMessage()], 500);
        }
    }

    // Login
    public function login(Request $request)
    {
        try {
            // Validate input
            $v = Validator::make($request->all(), [
                'email' => 'required|email',
                'password' => 'required|string'
            ]);

            if ($v->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validation failed',
                    'errors' => $v->errors()
                ], 422);
            }

            $email = $request->email;
            $ip = $request->ip();

            // Attempt to fetch user
            $u = $this->repo->getUserByEmail($email);

            // User not found
            if (!$u) {
                try {
                    DB::insert(
                        "INSERT INTO usr_failed_logins (email, ip_address, reason, created_at) VALUES (?, ?, ?, NOW())",
                        [$email, $ip, 'User not found']
                    );
                } catch (\Throwable $e) {
                    // ignore logging failure (permission etc) to keep login flow consistent
                }

                return response()->json([
                    'status' => 'error',
                    'message' => 'Invalid credentials'
                ], 401);
            }

            // Invalid password
            if (!Hash::check($request->password, $u['password'])) {
                try {
                    DB::insert(
                        "INSERT INTO usr_failed_logins (email, ip_address, reason, created_at) VALUES (?, ?, ?, NOW())",
                        [$email, $ip, 'Invalid password']
                    );
                } catch (\Throwable $e) {
                    // ignore logging failure
                }

                return response()->json([
                    'status' => 'error',
                    'message' => 'Invalid credentials'
                ], 401);
            }

            // Disabled user
            if (!$u['is_enabled']) {
                try {
                    DB::insert(
                        "INSERT INTO usr_failed_logins (email, ip_address, reason, created_at) VALUES (?, ?, ?, NOW())",
                        [$email, $ip, 'User account disabled']
                    );
                } catch (\Throwable $e) {
                    // ignore logging failure
                }

                return response()->json([
                    'status' => 'error',
                    'message' => 'Account disabled'
                ], 403);
            }

            // Passed all checks — generate token and login
            $token = $this->repo->createTokenForUser($u['id']);
            $full = $this->repo->getUserById($u['id']);

            // Log successful login (best-effort)
            try {
                DB::insert(
                    "INSERT INTO usr_user_logins (user_id, ip_address, logged_in_at) VALUES (?, ?, NOW())",
                    [$u['id'], $ip]
                );
            } catch (\Throwable $e) {
                // ignore logging failure (permissions etc), but still return success
            }

            return response()->json([
                'status' => 'success',
                'data' => [
                    'user' => $full,
                    'token' => $token
                ]
            ]);
        } catch (\Illuminate\Database\QueryException $e) {
            // Handle database errors
            return response()->json([
                'status' => 'error',
                'message' => 'Database error: ' . $e->getMessage()
            ], 500);
        } catch (\Throwable $e) {
            // Catch all other unexpected errors
            return response()->json([
                'status' => 'error',
                'message' => 'An unexpected error occurred',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Manual token check helper.
     * Throws HttpResponseException with JSON 401 response if not authorized.
     * Returns the repository user object (full structure from getUserById).
     */
    protected function authenticate(Request $request)
    {
        $token = $request->bearerToken();

        if (!$token) {
            $resp = response()->json(['status'=>'error','message'=>'Unauthorized'], 401);
            throw new HttpResponseException($resp);
        }

        $user = $this->repo->getUserByToken($token);
        if (!$user) {
            $resp = response()->json(['status'=>'error','message'=>'Unauthorized'], 401);
            throw new HttpResponseException($resp);
        }

        return $user;
    }

    // Me
    public function me(Request $request)
    {
        $user = $this->authenticate($request);
        return response()->json(['status'=>'success','data'=>$user]);
    }

    // Logout
    public function logout(Request $request)
    {
        $token = $request->bearerToken();
        if ($token) {
            $user = $this->repo->getUserByToken($token);
            if ($user) {
                // Update the most recent login record's logged_out_at using subquery (postgres-compatible)
                try {
                    DB::update("
                        UPDATE usr_user_logins
                        SET logged_out_at = NOW()
                        WHERE id = (
                            SELECT id FROM usr_user_logins
                            WHERE user_id = ? AND logged_out_at IS NULL
                            ORDER BY logged_in_at DESC
                            LIMIT 1
                        )
                    ", [$user['user']['id']]);
                } catch (\Throwable $e) {
                    // ignore logging failure
                }
            }

            $this->repo->revokeToken($token);
        }

        return response()->json(['status' => 'success', 'message' => 'Logged out']);
    }

    // Admin: list users
    public function index(Request $request)
    {
        $this->authenticate($request);
        $list = $this->repo->listUsers();
        return response()->json(['status'=>'success','data'=>$list]);
    }

    // Admin: update user
    public function update(Request $request, $id)
    {
        $this->authenticate($request);
        $data = $request->only(['name','email','is_enabled','phone_number','address','gender','dob','role_id']);
        $res = $this->repo->updateUser((int)$id, $data);
        return response()->json(['status'=>'success','data'=>$res]);
    }

    // Dashboard - summary
    public function dashboard(Request $request)
    {
        $user = $this->authenticate($request);

        $totalUsers = $this->repo->countUsers();
        $activeUsers = $this->repo->countActiveUsers();
        $roles = $this->repo->listRoles();
        $latestUsers = $this->repo->latestUsers(5);
        $recentLogins = $this->repo->recentLogins(5);
        // If the repository has recentFailedLogins(), it will return them; otherwise fallback to empty array
        $failedLogins = method_exists($this->repo, 'recentFailedLogins') ? $this->repo->recentFailedLogins(5) : [];

        return response()->json([
            'status' => 'success',
            'data' => [
                'current_user' => $user,
                'stats' => [
                    'total_users' => $totalUsers,
                    'active_users' => $activeUsers,
                    'roles' => $roles,
                ],
                'latest_users' => $latestUsers,
                'recent_logins' => $recentLogins,
                'failed_logins' => $failedLogins
            ],
        ]);
    }

    // Admin: delete user
    public function destroy(Request $request, $id)
    {
        $this->authenticate($request);
        $this->repo->deleteUser((int)$id);
        return response()->json(['status'=>'success','message'=>'User deleted']);
    }
}
