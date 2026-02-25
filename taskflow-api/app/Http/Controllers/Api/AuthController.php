<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Laravel\Socialite\Facades\Socialite;

class AuthController extends Controller
{
    /**
     * POST /api/register
     */
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'username' => 'required|string|max:255',
            'email'    => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $user = User::create([
            'username' => $validated['username'],
            'email'    => $validated['email'],
            'password' => Hash::make($validated['password']),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registration successful',
            'data'    => [
                'user'  => $user,
                'token' => $token,
            ],
        ], 201);
    }

    /**
     * POST /api/login
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email'    => 'required|string|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data'    => [
                'user'  => $user,
                'token' => $token,
            ],
        ], 200);
    }

    /**
     * POST /api/logout  (requires auth:sanctum)
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ], 200);
    }

    /**
     * GET /api/user  (requires auth:sanctum)
     */
    public function user(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data'    => $request->user(),
        ], 200);
    }

    /**
     * POST /api/auth/github
     * Receives a GitHub access token from the Flutter app,
     * fetches the GitHub user, and creates/logs in the user.
     */
    public function githubCallback(Request $request): JsonResponse
    {
        $request->validate([
            'access_token' => 'required|string',
        ]);

        try {
            $githubUser = Socialite::driver('github')
                ->stateless()
                ->userFromToken($request->access_token);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid GitHub token',
            ], 401);
        }

        // Find existing user by github_id or email, or create new
        $user = User::where('github_id', $githubUser->getId())->first();

        if (! $user) {
            $user = User::where('email', $githubUser->getEmail())->first();
            if ($user) {
                // Link GitHub to existing account
                $user->update([
                    'github_id' => $githubUser->getId(),
                    'avatar'    => $githubUser->getAvatar(),
                ]);
            } else {
                // Create brand-new user
                $user = User::create([
                    'username'      => $githubUser->getName() ?? $githubUser->getNickname(),
                    'email'     => $githubUser->getEmail() ?? $githubUser->getId() . '@github.user',
                    'github_id' => $githubUser->getId(),
                    'avatar'    => $githubUser->getAvatar(),
                    'password'  => null,
                ]);
            }
        } else {
            // Update avatar on every login
            $user->update(['avatar' => $githubUser->getAvatar()]);
        }

        $token = $user->createToken('github_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'GitHub login successful',
            'data'    => [
                'user'  => $user,
                'token' => $token,
            ],
        ], 200);
    }
}