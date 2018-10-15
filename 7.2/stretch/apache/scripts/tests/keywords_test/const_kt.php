<?php
class MyClass
{
    const CONSTANT = 'constant value';

    function showConstant() {
        echo  self::CONSTANT . "\n";
    }
}

echo MyClass::CONSTANT . "\n";

$classname = "MyClass";
echo $classname::CONSTANT . "\n"; // As of PHP 5.3.0

$class = new MyClass();
$class->showConstant();

echo $class::CONSTANT."\n"; // As of PHP 5.3.0
?>

<?php
class foo {
    // As of PHP 5.3.0
    const BAR = <<<'EOT'
bar
EOT;
    // As of PHP 5.3.0
    const BAZ = <<<EOT
baz
EOT;
}
?>

<?php
const ONE = 1;

class foo1 {
    // As of PHP 5.6.0
    const TWO = ONE * 2;
    const THREE = ONE + self::TWO;
    const SENTENCE = 'The value of THREE is '.self::THREE;
}
?>
