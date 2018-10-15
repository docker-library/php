<?php
class Foo
{
    public $bar;
    
    public function __construct() {
        $this->bar = function() {
            return 42;
        };
    }
}

$obj = new Foo();

// as of PHP 5.3.0:
$func = $obj->bar;
echo $func(), PHP_EOL;
