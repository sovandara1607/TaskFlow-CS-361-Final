<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\NotificationController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::get('/up', function () {
    return response()->json([
        'message' => 'TaskFlow API is running',
    ]);
});

// ── Public Auth Endpoints ───────────────────────────────────────────────
Route::post('/register',      [AuthController::class, 'register']);
Route::post('/login',         [AuthController::class, 'login']);
Route::post('/auth/github',   [AuthController::class, 'githubCallback']);

// ── Protected Endpoints (require Bearer token) ─────────────────────────
Route::middleware('auth:sanctum')->group(function () {
   Route::get('/user',         [AuthController::class, 'user']);
   Route::put('/user',         [AuthController::class, 'updateProfile']);
   Route::post('/logout',      [AuthController::class, 'logout']);

   // ── Task CRUD ──
   Route::get('/tasks/scheduled', [TaskController::class, 'scheduled']);
   Route::get('/tasks',          [TaskController::class, 'index']);
   Route::post('/tasks',         [TaskController::class, 'store']);
   Route::get('/tasks/{id}',     [TaskController::class, 'show']);
   Route::put('/tasks/{id}',     [TaskController::class, 'update']);
   Route::delete('/tasks/{id}',  [TaskController::class, 'destroy']);

   // ── Notifications ──
   Route::get('/notifications',              [NotificationController::class, 'index']);
   Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
   Route::put('/notifications/read-all',     [NotificationController::class, 'markAllAsRead']);
   Route::put('/notifications/{id}/read',    [NotificationController::class, 'markAsRead']);
   Route::delete('/notifications/{id}',      [NotificationController::class, 'destroy']);
   Route::delete('/notifications',           [NotificationController::class, 'destroyAll']);
});
