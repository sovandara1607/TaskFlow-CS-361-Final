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
    * Retrieve the authenticated user's tasks.
    */
   public function index(Request $request): JsonResponse
   {
      $tasks = $request->user()
         ->tasks()
         ->orderBy('created_at', 'desc')
         ->get();

      return response()->json([
         'success' => true,
         'message' => 'Tasks retrieved successfully',
         'data'    => $tasks,
      ], 200);
   }

   /**
    * POST /api/tasks
    */
   public function store(Request $request): JsonResponse
   {
      $validated = $request->validate([
         'title'       => 'required|string|max:255',
         'description' => 'nullable|string',
         'status'      => 'nullable|string|in:pending,in_progress,completed',
         'due_date'    => 'nullable|date',
         'category'    => 'nullable|string|in:general,school,work,home,personal',
      ]);

      $task = $request->user()->tasks()->create([
         'title'       => $validated['title'],
         'description' => $validated['description'] ?? '',
         'status'      => $validated['status'] ?? 'pending',
         'due_date'    => $validated['due_date'] ?? null,
         'category'    => $validated['category'] ?? 'general',
      ]);

      return response()->json([
         'success' => true,
         'message' => 'Task created successfully',
         'data'    => $task,
      ], 201);
   }

   /**
    * GET /api/tasks/{id}
    */
   public function show(Request $request, int $id): JsonResponse
   {
      $task = $request->user()->tasks()->find($id);

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
    */
   public function update(Request $request, int $id): JsonResponse
   {
      $task = $request->user()->tasks()->find($id);

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
         'category'    => 'nullable|string|in:general,school,work,home,personal',
      ]);

      $task->update([
         'title'       => $validated['title'],
         'description' => $validated['description'] ?? $task->description,
         'status'      => $validated['status'] ?? $task->status,
         'due_date'    => $validated['due_date'] ?? $task->due_date,
         'category'    => $validated['category'] ?? $task->category,
      ]);

      return response()->json([
         'success' => true,
         'message' => 'Task updated successfully',
         'data'    => $task,
      ], 200);
   }

   /**
    * DELETE /api/tasks/{id}
    */
   public function destroy(Request $request, int $id): JsonResponse
   {
      $task = $request->user()->tasks()->find($id);

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
