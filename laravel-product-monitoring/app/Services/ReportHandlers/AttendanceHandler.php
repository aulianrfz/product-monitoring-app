<?php
namespace App\Services\ReportHandlers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AttendanceHandler implements ReportHandlerInterface
{
    public function handle(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'status' => 'required|in:check_in,check_out',
            'timestamp' => 'required|date_format:Y-m-d H:i:s',
        ]);

        if ($v->fails()) {
            return response()->json(['success' => false, 'errors' => $v->errors()], 422);
        }

        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthenticated'], 401);
        }

        DB::table('attendances')->insert([
            'user_id' => $user->id,
            'status' => $request->input('status'),
            'timestamp' => $request->input('timestamp'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Attendance recorded',
            'data' => [
                'user' => $user->name,
                'status' => $request->input('status'),
                'timestamp' => $request->input('timestamp'),
            ],
        ]);
    }
}
