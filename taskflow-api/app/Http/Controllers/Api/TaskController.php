<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class TaskController extends Controller
{
   /**
    * GET /api/tasks
    * Retrieve all tasks ordered by newest first.
    */
   public function index(): JsonResponse
   {
      $tasks = Task::orderBy('created_at', 'desc')->get();

      return response()->json([
         'success' => true,
         'message' => 'Tasks retrieved successfully',
         'data'    => $tasks,
      ], 200);
   }

   /**
    * POST /api/tasks
    * Create a new task.
    */
   public function store(Request $request): JsonResponse
   {
      $validated = $request->validate([
         'title'       => 'required|string|max:255',
         'description' => 'nullable|string',
         'status'      => 'nullable|string|in:pending,in_progress,completed',
         'due_date'    => 'nullable|date',
      ]);

      $task = Task::create([
         'title'       => $validated['title'],
         'description' => $validated['description'] ?? '',
         'status'      => $validated['status'] ?? 'pending',
         'due_date'    => $validated['due_date'] ?? null,
      ]);

      return response()->json([
         'success' => true,
         'message' => 'Task created successfully',
         'data'    => $task,
      ], 201);
   }

   /**
    * GET /api/tasks/{id}
    * Retrieve a single task.
    */
   public function show(int $id): JsonResponse
   {
      $task = Task::find($id);

      if (!$task) {
         return response()->json([
            'success' => false,
            'message' => 'Task not found',
         ], 404);
      }

      return response()->json([
         'success' => true,
         'message' => 'Task retrieved successfully',
         'data'    => $task,
      ], 200);
   }

   /**
    * PUT /api/tasks/{id}
    * Update an existing task.
    */
   public function update(Request $request, int $id): JsonResponse
   {
      $task = Task::find($id);

      if (!$task) {
         return response()->json([
            'success' => false,
            'message' => 'Task not found',
         ], 404);
      }

      $validated = $request->validate([
         'title'       => 'required|string|max:255',
         'description' => 'nullable|string',
         'status'      => 'nullable|string|in:pending,in_progress,completed',
         'due_date'    => 'nullable|date',
      ]);

      $task->update([
         'title'       => $validated['title'],
         'description' => $validated['description'] ?? $task->description,
         'status'      => $validated['status'] ?? $task->status,
         'due_date'    => $validated['due_date'] ?? $task->due_date,
      ]);

      return response()->json([
         'success' => true,
         'message' => 'Task updated successfully',
         'data'    => $task,
      ], 200);
   }

   /**
    * DELETE /api/tasks/{id}
    * Delete a task.
    */
   public function destroy(int $id): JsonResponse
   {
      $task = Task::find($id);

      if (!$task) {
         return response()->json([
            'success' => false,
            'message' => 'Task not found',
         ], 404);
      }

      $task->delete();

      return response()->json([
         'success' => true,
         'message' => 'Task deleted successfully',
      ], 200);
   }
}
