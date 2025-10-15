<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User
        User::factory()->create([
            'name' => 'Fajar',
            'email' => 'fajar@gmail.com',
            'password' => '123456',
        ]);

        // Stores
        DB::table('stores')->insert([
            ['code' => 'TOK01', 'name' => 'TOKO INDOJUNI', 'address' => 'Jl. Merdeka No. 1', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'TOK02', 'name' => 'TOKO TINTIN', 'address' => 'Jl. Asia Afrika No. 2', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'TOK03', 'name' => 'TOKO WARASANGIT', 'address' => 'Jl. Sudirman No. 3', 'created_at' => now(), 'updated_at' => now()],
        ]);

        // Products
        DB::table('products')->insert([
            ['name' => 'Keripik Kentang Xie-xie', 'barcode' => '111111', 'size' => '250mL', 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Biskuit Kelapa Ni-hao', 'barcode' => '222222', 'size' => '100mL', 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Coklat Kacang Peng-you', 'barcode' => '333333', 'size' => '50mL', 'created_at' => now(), 'updated_at' => now()],
        ]);
    }
}
