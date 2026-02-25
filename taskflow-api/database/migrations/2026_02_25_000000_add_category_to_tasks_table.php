<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
   /**
    * Run the migrations.
    * Adds a category column to the tasks table.
    */
   public function up(): void
   {
      Schema::table('tasks', function (Blueprint $table) {
         $table->string('category')->default('general')->after('status');
      });
   }

   /**
    * Reverse the migrations.
    */
   public function down(): void
   {
      Schema::table('tasks', function (Blueprint $table) {
         $table->dropColumn('category');
      });
   }
};
