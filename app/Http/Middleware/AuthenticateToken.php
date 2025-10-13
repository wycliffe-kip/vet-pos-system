<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Modules\Auth\Repositories\AuthRepository;

class AuthenticateToken
{
    protected AuthRepository $repo;

    public function __construct(AuthRepository $repo)
    {
        $this->repo = $repo;
    }

    public function handle(Request $request, Closure $next)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(['status'=>'error','message'=>'Unauthorized'], 401);
        }

        $user = $this->repo->getUserByToken($token);

        if (!$user) {
            return response()->json(['status'=>'error','message'=>'Unauthorized'], 401);
        }

        $request->setUserResolver(fn() => (object)$user['user']);

        return $next($request);
    }
}
