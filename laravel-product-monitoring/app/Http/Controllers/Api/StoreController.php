<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Store; 

class StoreController extends Controller
{
    public function index(Request $request)
    {
        $stores = Store::select('id','code', 'name', 'address')->get();

        return response()->json([
            'success' => true,
            'data' => $stores
        ]);
    }
}
