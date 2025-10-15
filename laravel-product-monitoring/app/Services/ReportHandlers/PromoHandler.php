<?php

namespace App\Services\ReportHandlers;

use App\Models\Promo;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class PromoHandler implements ReportHandlerInterface
{
    public function handle(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'store_id' => 'required|exists:stores,id',
            'product_id' => 'required|exists:products,id',
            'normal_price' => 'required|numeric|min:0',
            'promo_price' => 'required|numeric|min:0|lt:normal_price',
        ]);

        $promo = Promo::create([
            'user_id' => Auth::id(),
            'store_id' => $validated['store_id'],
            'product_id' => $validated['product_id'],
            'normal_price' => $validated['normal_price'],
            'promo_price' => $validated['promo_price'],
        ]);

        return response()->json([
            'success' => true,
            'data' => $promo
        ]);
    }
}
