<?php
namespace App\Services\ReportHandlers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

interface ReportHandlerInterface
{
    public function handle(Request $request): JsonResponse;
}
