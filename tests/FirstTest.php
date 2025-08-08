<?php

declare(strict_types=1);

namespace App\Tests;

use PHPUnit\Framework\TestCase;
use App\HelloWorld;

final class FirstTest extends TestCase
{
    public function testHelloWorld(): void
    {
        $foo = new HelloWorld();

        self::assertEquals('Hello World', $foo->helloWorld());
    }
}
