<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

use App\Services\ReportHandlers\AttendanceHandler;
use App\Services\ReportHandlers\ProductAvailabilityHandler;
use App\Services\ReportHandlers\PromoHandler;

class ReportController extends Controller
{
    protected $handlers = [];

    public function __construct(
        AttendanceHandler $attendanceHandler,
        ProductAvailabilityHandler $productHandler,
        PromoHandler $promoHandler
    ) {
        $this->handlers = [
            'attendance' => $attendanceHandler,
            'product' => $productHandler,
            'promo' => $promoHandler,
        ];
    }

    public function store(Request $request, $context)
    {
        Log::info("Report received with context: {$context}");

        if (! isset($this->handlers[$context])) {
            return response()->json(['success' => false, 'message' => 'Unknown context'], 400);
        }

        $handler = $this->handlers[$context];

        return $handler->handle($request);
    }
}
