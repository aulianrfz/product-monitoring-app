<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $storeId = $request->query('store_id');
        $user = $request->user();

        $products = Product::with(['productAvailabilities' => function ($query) use ($storeId, $user) {
            $query->where('store_id', $storeId)
                  ->where('user_id', $user->id)
                  ->select('id', 'product_id', 'available');
        }])
        ->select('id', 'name', 'barcode', 'size')
        ->get()
        ->map(function ($product) {
            $product->available = $product->productAvailabilities->first()->available ?? false;
            unset($product->productAvailabilities);
            return $product;
        });

        return response()->json([
            'success' => true,
            'data' => $products,
        ]);
    }
}
