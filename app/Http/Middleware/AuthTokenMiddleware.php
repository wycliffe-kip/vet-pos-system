<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Modules\Auth\Repositories\AuthRepository;
use Illuminate\Http\Exceptions\HttpResponseException;

class AuthTokenMiddleware
{
    protected AuthRepository $repo;

    public function __construct(AuthRepository $repo)
    {
        $this->repo = $repo;
    }

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        $token = $request->bearerToken();
        if (!$token) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => 'Unauthorized'
            ], 401));
        }

        $user = $this->repo->getUserByToken($token);
        if (!$user) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => 'Unauthorized'
            ], 401));
        }

        // Optionally attach the authenticated user to the request
        $request->attributes->set('auth_user', $user);

        return $next($request);
    }
}
