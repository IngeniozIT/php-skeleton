<?php

declare(strict_types=1);

namespace IngeniozIT\Skeleton\Tests;

use PHPUnit\Framework\TestCase;
use IngeniozIT\Skeleton\HelloWorld;

final class FirstTest extends TestCase
{
    public function testHelloWorld(): void
    {
        $hello = new HelloWorld();

        $message = $hello->sayHello();

        self::assertSame('Hello World!', $message);
    }
}
