<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic feature test example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }

    /**
     * Test the health endpoint.
     */
    public function test_health_endpoint(): void
    {
        $response = $this->get('/health');

        $response->assertStatus(200)
                 ->assertJson([
                     'status' => 'ok'
                 ]);
    }

    /**
     * Test the API status endpoint.
     */
    public function test_api_status_endpoint(): void
    {
        $response = $this->get('/api/status');

        $response->assertStatus(200)
                 ->assertJson([
                     'api' => 'Laravel Docker API',
                     'version' => '1.0.0',
                     'status' => 'active'
                 ]);
    }

    /**
     * Test that 404 pages return the correct status.
     */
    public function test_404_page(): void
    {
        $response = $this->get('/non-existent-page');

        $response->assertStatus(404);
    }
}
