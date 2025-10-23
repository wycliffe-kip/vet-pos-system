<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\Exceptions\HttpResponseException;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  Request  $request
     * @param  Closure  $next
     * @param  string   $roles  Comma-separated role names
     */
    public function handle(Request $request, Closure $next, string $roles)
    {
        // Get the authenticated user attached by AuthTokenMiddleware
        $user = $request->get('auth_user');

        if (!$user) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => 'Unauthorized'
            ], 401));
        }

        // Convert roles parameter to array
        $requiredRoles = array_map('trim', explode(',', $roles));

        // Get the user's roles from the repository structure
        $userRoles = array_map(fn($r) => $r['name'], $user['roles'] ?? []);

        // Check if user has at least one of the required roles
        $hasRole = count(array_intersect($requiredRoles, $userRoles)) > 0;

        if (!$hasRole) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => 'Forbidden: insufficient role'
            ], 403));
        }

        return $next($request);
    }
}
