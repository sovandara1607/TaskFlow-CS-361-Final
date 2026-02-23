<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
   /**
    * Run the migrations.
    * Creates the tasks table in MySQL.
    */
   public function up(): void
   {
      Schema::create('tasks', function (Blueprint $table) {
         $table->id();                                   // bigint unsigned auto-increment primary key
         $table->string('title');                         // task title
         $table->text('description')->nullable();        // task description
         $table->enum('status', [                        // task status
            'pending',
            'in_progress',
            'completed',
         ])->default('pending');
         $table->date('due_date')->nullable();           // optional due date
         $table->timestamps();                           // created_at & updated_at
      });
   }

   /**
    * Reverse the migrations.
    */
   public function down(): void
   {
      Schema::dropIfExists('tasks');
   }
};
