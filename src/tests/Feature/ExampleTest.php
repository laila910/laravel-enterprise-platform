<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * Test the welcome page.
     */
    public function test_welcome_page(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200)
                 ->assertSee('Laravel Enterprise Platform');
    }

    /**
     * Test a basic health check.
     */
    public function test_basic_health_check(): void
    {
        $response = $this->get('/health');

        $response->assertStatus(200);
        // Just check that it returns some content
        $this->assertNotEmpty($response->getContent());
    }

    /**
     * Test 404 handling.
     */
    public function test_404_page(): void
    {
        $response = $this->get('/non-existent-route');

        $response->assertStatus(404);
    }
}
