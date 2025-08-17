<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{
    /**
     * Test basic application functionality.
     */
    public function test_application_constants(): void
    {
        $this->assertTrue(true);
        $this->assertGreaterThanOrEqual('8.3', PHP_VERSION);
    }

    /**
     * Test string operations.
     */
    public function test_string_operations(): void
    {
        $string = "Laravel Enterprise Platform";
        
        $this->assertStringContainsString("Laravel", $string);
        $this->assertEquals(27, strlen($string));
    }

    /**
     * Test array operations.
     */
    public function test_array_operations(): void
    {
        $array = [1, 2, 3, 4, 5];
        
        $this->assertCount(5, $array);
        $this->assertEquals(15, array_sum($array));
    }
}
