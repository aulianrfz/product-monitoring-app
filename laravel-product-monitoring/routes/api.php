<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\StoreController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\PromoController;
use App\Http\Controllers\Api\AttendanceController;

Route::prefix('v1')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/report/{context}', [ReportController::class, 'store']);

        Route::get('/stores', [StoreController::class, 'index']); 
        Route::get('/products', [ProductController::class, 'index']); 
    
        Route::get('/promos', [PromoController::class, 'index']);
        Route::put('/promos/{id}', [PromoController::class, 'update']);
        Route::delete('/promos/{id}', [PromoController::class, 'destroy']);

        Route::get('/attendance/history', [AttendanceController::class, 'history']);
    });
});
