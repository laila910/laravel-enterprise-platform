<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic unit test example.
     */
    public function test_that_true_is_true(): void
    {
        $this->assertTrue(true);
    }

    /**
     * Test basic PHP functionality.
     */
    public function test_php_version(): void
    {
        $this->assertGreaterThanOrEqual('8.3', PHP_VERSION);
    }

    /**
     * Test array operations.
     */
    public function test_array_operations(): void
    {
        $array = [1, 2, 3, 4, 5];
        
        $this->assertCount(5, $array);
        $this->assertContains(3, $array);
        $this->assertEquals(15, array_sum($array));
    }

    /**
     * Test string operations.
     */
    public function test_string_operations(): void
    {
        $string = "Laravel Enterprise Platform";
        
        $this->assertStringContainsString("Laravel", $string);
        $this->assertStringStartsWith("Laravel", $string);
        $this->assertStringEndsWith("Platform", $string);
    }
}
