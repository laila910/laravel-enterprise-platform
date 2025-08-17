<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;

class HealthController extends Controller
{
    /**
     * Health check endpoint.
     */
    public function health(): JsonResponse
    {
        return response()->json([
            'status' => 'ok',
            'timestamp' => now()->toISOString(),
            'app' => config('app.name'),
            'environment' => app()->environment()
        ]);
    }

    /**
     * API status endpoint.
     */
    public function status(): JsonResponse
    {
        return response()->json([
            'api' => 'Laravel Docker API',
            'version' => '1.0.0',
            'status' => 'active',
            'php_version' => PHP_VERSION,
            'laravel_version' => app()->version()
        ]);
    }
}
