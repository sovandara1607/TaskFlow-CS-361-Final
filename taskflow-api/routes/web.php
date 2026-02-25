<?php

use Illuminate\Support\Facades\Route;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Laravel\Socialite\Facades\Socialite;

Route::get('/', function () {
    return view('welcome');
});

/*
|--------------------------------------------------------------------------
| GitHub OAuth Routes
|--------------------------------------------------------------------------
| /auth/github/redirect  → Sends user to GitHub to authorise
| /login/oauth2/code/github → GitHub redirects back here with ?code=XXX
*/
Route::get('/auth/github/redirect', function () {
    return Socialite::driver('github')->stateless()->redirect();
});

Route::get('/login/oauth2/code/github', function () {
    try {
        $githubUser = Socialite::driver('github')->stateless()->user();
    } catch (\Exception $e) {
        \Illuminate\Support\Facades\Log::error('GitHub OAuth error: ' . $e->getMessage());
        return response('GitHub authentication failed: ' . $e->getMessage(), 401);
    }

    // Find existing user by github_id or email, or create new
    $user = User::where('github_id', $githubUser->getId())->first();

    if (! $user) {
        $user = User::where('email', $githubUser->getEmail())->first();
        if ($user) {
            $user->update([
                'github_id' => $githubUser->getId(),
                'avatar'    => $githubUser->getAvatar(),
            ]);
        } else {
            $user = User::create([
                'username'  => $githubUser->getName() ?? $githubUser->getNickname(),
                'email'     => $githubUser->getEmail() ?? $githubUser->getId() . '@github.user',
                'github_id' => $githubUser->getId(),
                'avatar'    => $githubUser->getAvatar(),
                'password'  => null,
            ]);
        }
    } else {
        $user->update(['avatar' => $githubUser->getAvatar()]);
    }

    $token = $user->createToken('github_token')->plainTextToken;

    // Redirect to custom URL scheme so the Flutter app receives the token
    return redirect("taskflow://auth?token={$token}");
});
