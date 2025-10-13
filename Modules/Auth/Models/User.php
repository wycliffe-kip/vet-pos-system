<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    protected $table = 'usr_users'; // use your custom table
    protected $primaryKey = 'id';
    protected $fillable = ['name', 'email', 'password', 'is_enabled'];
    protected $hidden = ['password', 'remember_token'];
}
