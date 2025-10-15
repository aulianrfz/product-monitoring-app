<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function history(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated'
            ], 401);
        }

        $attendances = Attendance::where('user_id', $user->id)
            ->orderBy('timestamp', 'desc')
            ->get(['id', 'status', 'timestamp']);

        return response()->json([
            'success' => true,
            'data' => $attendances,
        ]);
    }
}
