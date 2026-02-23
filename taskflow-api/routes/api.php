<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TaskController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group.
|
*/

// ── Task CRUD Endpoints ─────────────────────────────────────────────────
Route::get('/tasks',       [TaskController::class, 'index']);    // GET    /api/tasks
Route::post('/tasks',      [TaskController::class, 'store']);    // POST   /api/tasks
Route::get('/tasks/{id}',  [TaskController::class, 'show']);     // GET    /api/tasks/{id}
Route::put('/tasks/{id}',  [TaskController::class, 'update']);   // PUT    /api/tasks/{id}
Route::delete('/tasks/{id}', [TaskController::class, 'destroy']); // DELETE /api/tasks/{id}
