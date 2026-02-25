<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
   use HasFactory;

   /**
    * The table associated with the model.
    */
   protected $table = 'tasks';

   /**
    * The attributes that are mass assignable.
    */
   protected $fillable = [
      'title',
      'description',
      'status',
      'due_date',
      'category',
      'user_id',
   ];

   /**
    * The attributes that should be cast.
    */
   protected $casts = [
      'due_date'   => 'date',
      'created_at' => 'datetime',
      'updated_at' => 'datetime',
   ];
}
