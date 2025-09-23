<?php

declare(strict_types=1);

namespace App\Tests;

use PHPUnit\Framework\TestCase;
use App\HelloWorld;

final class HelloWorldTest extends TestCase
{
    public function testUnitTestsAreWorking(): void
    {
        $foo = new HelloWorld();

        self::assertEquals('Hello, world!', $foo->helloWorld());
    }
}
