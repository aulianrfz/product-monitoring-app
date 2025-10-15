<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Store extends Model
{
    use HasFactory;

    protected $fillable = ['code', 'name', 'address'];

    public function productAvailabilities()
    {
        return $this->hasMany(ProductAvailability::class);
    }

    public function promos()
    {
        return $this->hasMany(Promo::class);
    }
}
