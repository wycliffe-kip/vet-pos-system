<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Modules\Auth\Repositories\AuthRepository;

class TokenAuth
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
            return response()->json(['status'=>'error', 'message'=>'Unauthorized: No token'], 401);
        }

        $user = $this->repo->getUserByToken($token);

        if (!$user) {
            return response()->json(['status'=>'error', 'message'=>'Unauthorized: Invalid token'], 401);
        }

        // Attach user to request so controllers can use $request->user()
        $request->setUserResolver(fn() => (object)$user);

        return $next($request);
    }
}
