<?php

/**
 * This file contains the LunrBaseTestMockTest class.
 *
 * @package    Lunr\Halo
 * @author     Heinz Wiesinger <heinz@m2mobi.com>
 * @copyright  2018, M2Mobi BV, Amsterdam, The Netherlands
 * @license    http://lunr.nl/LICENSE MIT License
 */

namespace Lunr\Halo\Tests;

/**
 * This class contains the tests for the unit test base class.
 *
 * @covers Lunr\Halo\LunrBaseTest
 */
class LunrBaseTestMockTest extends LunrBaseTestTest
{

    /**
     * Test mock_function()
     *
     * @covers Lunr\Halo\LunrBaseTest::mock_function()
     */
    public function testMockFunction()
    {
        $this->mock_function('is_int', function (){ return 'Nope!'; });

        $this->assertEquals('Nope!', is_int(1));

        $this->unmock_function('is_int');
    }

    /**
     * Test mock_function()
     *
     * @covers Lunr\Halo\LunrBaseTest::mock_function()
     */
    public function testMockFunctionWithString()
    {
        $this->mock_function('is_int', "return 'Nope!';");

        $this->assertEquals('Nope!', is_int(1));

        $this->unmock_function('is_int');
    }

    /**
     * Test unmock_function()
     *
     * @covers Lunr\Halo\LunrBaseTest::unmock_function()
     */
    public function testUnmockFunction()
    {
        $this->mock_function('is_int', function (){ return 'Nope!'; });

        $this->assertEquals('Nope!', is_int(1));

        $this->unmock_function('is_int');

        $this->assertTrue(is_int(1));
    }

    /**
     * Test mock_method()
     *
     * @covers Lunr\Halo\LunrBaseTest::mock_method()
     */
    public function testMockMethod()
    {
        $this->mock_method([ '\Lunr\Halo\Tests\MockClass', 'baz' ], function (){ return 'Nope!'; });

        $class = new MockClass();

        $this->assertEquals('Nope!', $class->baz());

        $this->unmock_method([ '\Lunr\Halo\Tests\MockClass', 'baz' ]);
    }

    /**
     * Test mock_method()
     *
     * @covers Lunr\Halo\LunrBaseTest::mock_method()
     */
    public function testMockMethodWithString()
    {
        $this->mock_method([ '\Lunr\Halo\Tests\MockClass', 'baz' ], "return 'Nope!';");

        $class = new MockClass();

        $this->assertEquals('Nope!', $class->baz());

        $this->unmock_method([ '\Lunr\Halo\Tests\MockClass', 'baz' ]);
    }

    /**
     * Test mock_method()
     *
     * @covers Lunr\Halo\LunrBaseTest::mock_method()
     */
    public function testMockMethodFromObject()
    {
        $this->mock_method([ $this->class, 'baz' ], function (){ return 'Nope!'; });

        $this->assertEquals('Nope!', $this->class->baz());

        $this->unmock_method([ $this->class, 'baz' ]);
    }

    /**
     * Test mock_method()
     *
     * @covers Lunr\Halo\LunrBaseTest::mock_method()
     */
    public function testMockMethodFromObjectWithString()
    {
        $this->mock_method([ $this->class, 'baz' ], "return 'Nope!';");

        $this->assertEquals('Nope!', $this->class->baz());

        $this->unmock_method([ $this->class, 'baz' ]);
    }

    /**
     * Test unmock_method()
     *
     * @covers Lunr\Halo\LunrBaseTest::unmock_method()
     */
    public function testUnmockMethod()
    {
        $this->mock_method([ '\Lunr\Halo\Tests\MockClass', 'baz' ], function (){ return 'Nope!'; });

        $class = new MockClass();

        $this->assertEquals('Nope!', $class->baz());

        $this->unmock_method([ '\Lunr\Halo\Tests\MockClass', 'baz' ]);

        $this->assertEquals('string', $class->baz());
    }

    /**
     * Test unmock_method()
     *
     * @covers Lunr\Halo\LunrBaseTest::unmock_method()
     */
    public function testUnmockMethodFromObject()
    {
        $this->markTestSkipped("uopz currently doesn't handling unmocking with class instances correctly.");

        $this->mock_method([ $this->class, 'baz' ], function (){ return 'Nope!'; });

        $this->assertEquals('Nope!', $this->class->baz());

        $this->unmock_method([ $this->class, 'baz' ]);

        $this->assertEquals('string', $this->class->baz());
    }

    /**
     * Test constant_redefine()
     *
     * @covers Lunr\Halo\LunrBaseTest::constant_redefine()
     */
    public function testConstantRedefine()
    {
        $this->assertSame('constant', $this->class::FOOBAR);

        $this->constant_redefine('Lunr\Halo\Tests\MockClass::FOOBAR', 'new value');

        $class = new MockClass();

        $this->assertSame('new value', $class::FOOBAR);

        $this->constant_redefine('Lunr\Halo\Tests\MockClass::FOOBAR', 'constant');

        $class = new MockClass();

        $this->assertSame('constant', $class::FOOBAR);
    }

}

?>