<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
   /**
    * Add an optional end datetime for scheduled tasks.
    */
   public function up(): void
   {
      Schema::table('tasks', function (Blueprint $table) {
         if (!Schema::hasColumn('tasks', 'ends_at')) {
            $table->dateTime('ends_at')->nullable()->after('scheduled_at');
         }
      });
   }

   /**
    * Reverse the migrations.
    */
   public function down(): void
   {
      Schema::table('tasks', function (Blueprint $table) {
         if (Schema::hasColumn('tasks', 'ends_at')) {
            $table->dropColumn('ends_at');
         }
      });
   }
};