<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
   public function up(): void
   {
      Schema::table('users', function (Blueprint $table) {
         $table->string('github_id')->nullable()->unique()->after('email');
         $table->string('avatar')->nullable()->after('github_id');
         // Allow password to be null for GitHub-only users
      });

      // Make password nullable (GitHub users won't have one)
      Schema::table('users', function (Blueprint $table) {
         $table->string('password')->nullable()->change();
      });

      // Add user_id foreign key to tasks table
      Schema::table('tasks', function (Blueprint $table) {
         $table->foreignId('user_id')->nullable()->after('id')
            ->constrained('users')->onDelete('cascade');
      });
   }

   public function down(): void
   {
      Schema::table('tasks', function (Blueprint $table) {
         $table->dropForeign(['user_id']);
         $table->dropColumn('user_id');
      });

      Schema::table('users', function (Blueprint $table) {
         $table->dropColumn(['github_id', 'avatar']);
         $table->string('password')->nullable(false)->change();
      });
   }
};