<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;

class TaskController extends Controller
{
   protected NotificationService $notificationService;

   public function __construct(NotificationService $notificationService)
   {
      $this->notificationService = $notificationService;
   }

   /**
    * GET /api/tasks
    * Retrieve the authenticated user's tasks.
    */
   public function index(Request $request): JsonResponse
   {
      $tasks = $request->user()
         ->tasks()
         ->orderByRaw('scheduled_at IS NULL, scheduled_at ASC')
         ->orderBy('created_at', 'desc')
         ->get();

      return response()->json([
         'success' => true,
         'message' => 'Tasks retrieved successfully',
         'data'    => $tasks,
      ], 200);
   }

   /**
    * GET /api/tasks/scheduled?filter=today|upcoming|overdue
    */
   public function scheduled(Request $request): JsonResponse
   {
      $filter = $request->query('filter', 'today');
      $now    = Carbon::now();
      $query  = $request->user()->tasks();

      switch ($filter) {
         case 'today':
            $query->whereDate('scheduled_at', $now->toDateString())
               ->orderBy('scheduled_at', 'asc');
            break;
         case 'upcoming':
            $query->where('scheduled_at', '>', $now)
               ->where('status', '!=', 'completed')
               ->orderBy('scheduled_at', 'asc');
            break;
         case 'overdue':
            $query->where('scheduled_at', '<', $now)
               ->where('status', '!=', 'completed')
               ->orderBy('scheduled_at', 'desc');
            break;
         default:
            $query->whereNotNull('scheduled_at')
               ->orderBy('scheduled_at', 'asc');
      }

      return response()->json([
         'success' => true,
         'message' => 'Scheduled tasks retrieved',
         'data'    => $query->get(),
      ], 200);
   }

   /**
    * POST /api/tasks
    */
   public function store(Request $request): JsonResponse
   {
      $validated = $request->validate([
         'title'            => 'required|string|max:255',
         'description'      => 'nullable|string',
         'status'           => 'nullable|string|in:pending,in_progress,completed',
         'due_date'         => 'nullable|date',
         'category'         => 'nullable|string|in:general,school,work,home,personal',
         'scheduled_at'     => 'nullable|date',
         'ends_at'          => 'nullable|date|after:scheduled_at',
         'reminder_minutes' => 'nullable|integer|min:0|max:1440',
      ]);

      $task = $request->user()->tasks()->create([
         'title'            => $validated['title'],
         'description'      => $validated['description'] ?? '',
         'status'           => $validated['status'] ?? 'pending',
         'due_date'         => $validated['due_date'] ?? null,
         'category'         => $validated['category'] ?? 'general',
         'scheduled_at'     => $validated['scheduled_at'] ?? null,
         'ends_at'          => $validated['ends_at'] ?? null,
         'reminder_minutes' => $validated['reminder_minutes'] ?? 15,
      ]);

      // Dispatch notification for task creation
      $this->notificationService->taskCreated(
         $request->user()->id,
         $task->id,
         $task->title
      );

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

      $oldStatus = $task->status;

      $validated = $request->validate([
         'title'            => 'required|string|max:255',
         'description'      => 'nullable|string',
         'status'           => 'nullable|string|in:pending,in_progress,completed',
         'due_date'         => 'nullable|date',
         'category'         => 'nullable|string|in:general,school,work,home,personal',
         'scheduled_at'     => 'nullable|date',
         'ends_at'          => 'nullable|date|after:scheduled_at',
         'reminder_minutes' => 'nullable|integer|min:0|max:1440',
      ]);

      $task->update([
         'title'            => $validated['title'],
         'description'      => $validated['description'] ?? $task->description,
         'status'           => $validated['status'] ?? $task->status,
         'due_date'         => $validated['due_date'] ?? $task->due_date,
         'category'         => $validated['category'] ?? $task->category,
         'scheduled_at'     => $validated['scheduled_at'] ?? $task->scheduled_at,
         'ends_at'          => $validated['ends_at'] ?? $task->ends_at,
         'reminder_minutes' => $validated['reminder_minutes'] ?? $task->reminder_minutes,
      ]);

      // Dispatch notification when task is marked completed
      $newStatus = $validated['status'] ?? $task->status;
      if ($newStatus === 'completed' && $oldStatus !== 'completed') {
         $this->notificationService->taskCompleted(
            $request->user()->id,
            $task->id,
            $task->title
         );
      }

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