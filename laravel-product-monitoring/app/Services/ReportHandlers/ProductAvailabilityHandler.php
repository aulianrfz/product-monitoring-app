<?php
namespace App\Services\ReportHandlers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ProductAvailabilityHandler implements ReportHandlerInterface
{
    public function handle(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'store_id' => 'required|integer',
            'product_id' => 'required|integer',
            'available' => 'required|boolean',
            'timestamp' => 'required|date_format:Y-m-d H:i:s',
        ]);

        if ($v->fails()) {
            return response()->json(['success' => false, 'errors' => $v->errors()], 422);
        }

        $user = $request->user();

        $existing = DB::table('product_availabilities')
            ->where('user_id', $user->id)
            ->where('store_id', $request->store_id)
            ->where('product_id', $request->product_id)
            ->first();

        if ($existing) {
            // update record kalau sudah ada
            DB::table('product_availabilities')
                ->where('id', $existing->id)
                ->update([
                    'available' => $request->available,
                    'timestamp' => $request->timestamp,
                    'updated_at' => now(),
                ]);
            $message = 'Product availability updated';
        } else {
            // buat record baru kalau belum ada
            DB::table('product_availabilities')->insert([
                'user_id' => $user->id,
                'store_id' => $request->store_id,
                'product_id' => $request->product_id,
                'available' => $request->available,
                'timestamp' => $request->timestamp,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $message = 'Product availability created';
        }

        return response()->json(['success' => true, 'message' => $message]);
    }
}
