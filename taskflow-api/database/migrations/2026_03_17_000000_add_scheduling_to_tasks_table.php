<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
   /**
    * Add scheduling columns to the tasks table.
    */
   public function up(): void
   {
      Schema::table('tasks', function (Blueprint $table) {
         $table->dateTime('scheduled_at')->nullable()->after('due_date');
         $table->integer('reminder_minutes')->nullable()->default(15)->after('scheduled_at');
      });
   }

   /**
    * Reverse the migrations.
    */
   public function down(): void
   {
      Schema::table('tasks', function (Blueprint $table) {
         $table->dropColumn(['scheduled_at', 'reminder_minutes']);
      });
   }
};
