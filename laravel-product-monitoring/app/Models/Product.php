<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'barcode', 'size'];

    public function productAvailabilities()
    {
        return $this->hasMany(ProductAvailability::class);
    }

    public function promos()
    {
        return $this->hasMany(Promo::class);
    }
}
