<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Promo;
use Illuminate\Http\Request;

class PromoController extends Controller
{
    public function index(Request $request)
    {
        $storeId = $request->query('store_id');
        $promos = Promo::with(['product'])
            ->when($storeId, fn($q) => $q->where('store_id', $storeId))
            ->get();

        return response()->json([
            'success' => true,
            'data' => $promos
        ]);
    }

    public function update(Request $request, $id)
    {
        $promo = Promo::findOrFail($id); 
        $promo->update([
            'normal_price' => $request->normal_price,
            'promo_price' => $request->promo_price,
        ]);
        return response()->json($promo);
    }

    public function destroy($id)
    {
        $promo = Promo::findOrFail($id);
        $promo->delete();
        return response()->json(['success' => true]);
    }

}
