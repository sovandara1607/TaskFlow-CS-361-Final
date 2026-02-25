<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\AuthController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// ── Public Auth Endpoints ───────────────────────────────────────────────
Route::post('/register',      [AuthController::class, 'register']);
Route::post('/login',         [AuthController::class, 'login']);
Route::post('/auth/github',   [AuthController::class, 'githubCallback']);

// ── Protected Endpoints (require Bearer token) ─────────────────────────
Route::middleware('auth:sanctum')->group(function () {
   Route::get('/user',         [AuthController::class, 'user']);
   Route::post('/logout',      [AuthController::class, 'logout']);

   // ── Task CRUD ──
   Route::get('/tasks',          [TaskController::class, 'index']);
   Route::post('/tasks',         [TaskController::class, 'store']);
   Route::get('/tasks/{id}',     [TaskController::class, 'show']);
   Route::put('/tasks/{id}',     [TaskController::class, 'update']);
   Route::delete('/tasks/{id}',  [TaskController::class, 'destroy']);
});
