<><> This is all outside of php <><> 

//This is a comment echo

<?php
#echo "Test abstract class - start\n Comment";
 echo "Test abstract class - start\n";
//Ignore echo
abstract class AbstractClass
  {
    // Force Extending class to define this method
    abstract protected function getValue();
    abstract protected function prefixValue($prefix);
    
    // Common method
    public function printOut()
      {
        print $this->getValue() . "\n";
      }
  }
class ConcreteClass1 extends AbstractClass
  {
    protected function getValue()
      {
        return "ConcreteClass1";
      }
    
    public function prefixValue($prefix)
      {
        return "{$prefix}ConcreteClass1";
      }
  }
class ConcreteClass2 extends AbstractClass
  {
    public function getValue()
      {
        return "ConcreteClass2";
      }
    
    public function prefixValue($prefix)
      {
        return "{$prefix}ConcreteClass2";
      }
  }
$class1 = new ConcreteClass1;
$class1->printOut();
echo $class1->prefixValue('FOO_') . "\n";
$class2 = new ConcreteClass2;
$class2->printOut();
echo $class2->prefixValue('FOO_') . "\n";
echo "Abstract class tests -done\n";
?>

echo Hey

<?php
echo "---Test and keyword - start---\n";
// --------------------
// foo() will never get called as those operators are short-circuit
$a = (false && foo());
$b = (true || foo());
$c = (false and foo());
$d = (true or foo());
// --------------------
// "||" has a greater precedence than "or"
// The result of the expression (false || true) is assigned to $e
// Acts like: ($e = (false || true))
$e = false || true;
// The constant false is assigned to $f before the "or" operation occurs
// Acts like: (($f = false) or true)
$f = false or true;
var_dump($e, $f);
// --------------------
// "&&" has a greater precedence than "and"
// The result of the expression (true && false) is assigned to $g
// Acts like: ($g = (true && false))
$g = true && false;
// The constant true is assigned to $h before the "and" operation occurs
// Acts like: (($h = true) and false)
$h = true and false;
var_dump($g, $h);
echo "---Test and keyword - done---\n";
?>

<?php
echo "---Test array keyword - start---\n";
$fruits = array(
    "fruits" => array(
        "a" => "orange",
        "b" => "banana",
        "c" => "apple"
    ),
    "numbers" => array(
        1,
        2,
        3,
        4,
        5,
        6
    ),
    "holes" => array(
        "first",
        5 => "second",
        "third"
    )
);
$array = array(
    1,
    1,
    1,
    1,
    1,
    8 => 1,
    4 => 1,
    19,
    3 => 13
);
print_r($array);
echo "---Test and keyword - done---\n";
?>

<?php
echo "---Test asort keyword - start---\n";
$fruits = array(
    "d" => "lemon",
    "a" => "orange",
    "b" => "banana",
    "c" => "apple"
);
asort($fruits);
foreach ($fruits as $key => $val)
  {
    echo "$key = $val\n";
  }
  
echo "---Test asort keyword - done---\n";
?>

<?php
echo "---Test compact keyword - start---\n";
$city  = "San Francisco";
$state = "CA";
$event = "SIGGRAPH";
$location_vars = array(
    "city",
    "state"
);
$result = compact("event", "nothing_here", $location_vars);
print_r($result);
echo "---Test compact keyword - done---\n";
?>

<?php
echo "---Test foreach,unset keyword - start---\n";
$arr = array(
    1,
    2,
    3,
    4
);
foreach ($arr as &$value)
  {
    $value = $value * 2;
  }
// $arr is now array(2, 4, 6, 8)
unset($value); // break the reference with the last element
echo "---Test foreach,unset keyword - done---\n";
?>


<?php
echo "---Test case keyword - start---\n";
$arr = array(
    'one',
    'two',
    'three',
    'four',
    'stop',
    'five'
);
while (list(, $val) = each($arr))
  {
    if ($val == 'stop')
      {
        break;
        /* You could also write 'break 1;' here. */
      }
    echo "$val<br />\n";
  }
/* Using the optional argument. */
$i = 0;
while (++$i)
  {
    switch ($i)
    {
        case 5:
            echo "At 5<br />\n";
            break 1;
        /* Exit only the switch. */
        case 10:
            echo "At 10; quitting<br />\n";
            break 2;
        /* Exit the switch and the while. */
        default:
            break;
    }
  }
echo "---Test case keyword - done---\n";
  
?>

<?php
echo "---Test class - start---\n";
// An example callback function
function my_callback_function()
  {
    echo 'hello world!';
  }
// An example callback method
class MyClass
  {
    static function myCallbackMethod()
      {
        echo 'Hello World!';
      }
  }
// Type 1: Simple callback
call_user_func('my_callback_function');
// Type 2: Static class method call
call_user_func(array(
    'MyClass',
    'myCallbackMethod'
));
// Type 3: Object method call
$obj = new MyClass();
call_user_func(array(
    $obj,
    'myCallbackMethod'
));
// Type 4: Static class method call (As of PHP 5.2.3)
call_user_func('MyClass::myCallbackMethod');
// Type 5: Relative static class method call (As of PHP 5.3.0)
class A
  {
    public static function who()
      {
        echo "A\n";
      }
  }
class B extends A
  {
    public static function who()
      {
        echo "B\n";
      }
  }
call_user_func(array(
    'B',
    'parent::who'
)); // A
// Type 6: Objects implementing __invoke can be used as callables (since PHP 5.3)
class C
  {
    public function __invoke($name)
      {
        echo 'Hello ', $name, "\n";
      }
  }
$c = new C();
call_user_func($c, 'PHP!');
echo "---Test class - done---\n";
?>

<?php
// Our closure
$double = function($a)
  {
    return $a * 2;
  };
// This is our range of numbers
$numbers = range(1, 5);
// Use the closure as a callback here to
// double the size of each element in our
// range
$new_numbers = array_map($double, $numbers);
print implode(' ', $new_numbers);
?>


<?php
if ($i == 0)
  {
    echo "i equals 0";
  }
elseif ($i == 1)
  {
    echo "i equals 1";
  }
elseif ($i == 2)
  {
    echo "i equals 2";
  }
switch ($i)
{
    case 0:
        echo "i equals 0";
        break;
    case 1:
        echo "i equals 1";
        break;
    case 2:
        echo "i equals 2";
        break;
}
?>

<?php
switch ($i)
{
    case "apple":
        echo "i is apple";
        break;
    case "bar":
        echo "i is bar";
        break;
    case "cake":
        echo "i is cake";
        break;
}
?>

<?php
function inverse($x)
  {
    if (!$x)
      {
        throw new Exception('Division by zero.');
      }
    return 1 / $x;
  }
try
  {
    echo inverse(5) . "\n";
    echo inverse(0) . "\n";
  }
catch (Exception $e)
  {
    echo 'Caught exception: ', $e->getMessage(), "\n";
  }
// Continue execution
echo "Hello World\n";
?>

<?php
class SimpleClass
  {
    // property declaration
    public $var = 'a default value';
    
    // method declaration
    public function displayVar()
      {
        echo $this->var;
      }
  }
?>


<?php
class SubObject
  {
    static $instances = 0;
    public $instance;
    
    public function __construct()
      {
        $this->instance = ++self::$instances;
      }
    
    public function __clone()
      {
        $this->instance = ++self::$instances;
      }
  }
class MyCloneable
  {
    public $object1;
    public $object2;
    
    function __clone()
      {
        // Force a copy of this->object, otherwise
        // it will point to same object.
        $this->object1 = clone $this->object1;
      }
  }
$obj = new MyCloneable();
$obj->object1 = new SubObject();
$obj->object2 = new SubObject();
$obj2 = clone $obj;
print("Original Object:\n");
print_r($obj);
print("Cloned Object:\n");
print_r($obj2);
?>

<?php
class MyClass1
  {
    const CONSTANT = 'constant value';
    
    function showConstant()
      {
        echo self::CONSTANT . "\n";
      }
  }
echo MyClass1::CONSTANT . "\n";
$classname = "MyClass1";
echo $classname::CONSTANT . "\n"; // As of PHP 5.3.0
$class = new MyClass1();
$class->showConstant();
echo $class::CONSTANT . "\n"; // As of PHP 5.3.0
?>


<?php
$stack = array(
    'first',
    'second',
    'third',
    'fourth',
    'fifth'
);
foreach ($stack AS $v)
  {
    if ($v == 'second')
        continue;
    if ($v == 'fourth')
        break;
    echo $v . '<br>';
  }
/* 
first 
third 
*/
$stack2 = array(
    'one' => 'first',
    'two' => 'second',
    'three' => 'third',
    'four' => 'fourth',
    'five' => 'fifth'
);
foreach ($stack2 AS $k => $v)
  {
    if ($v == 'second')
        continue;
    if ($k == 'three')
        continue;
    if ($v == 'fifth')
        break;
    echo $k . ' ::: ' . $v . '<br>';
  }
/* 
one ::: first 
four ::: fourth 
*/
?>

<?php
switch ($i)
{
    case "apple":
        echo "i is apple";
        break;
    case "bar":
        echo "i is bar";
        break;
    case "cake":
        echo "i is cake";
        break;
}
?>

<?php
switch ($i)
{
    case 0:
        echo "i equals 0";
        break;
    case 1:
        echo "i equals 1";
        break;
    case 2:
        echo "i equals 2";
        break;
    default:
        echo "i is not equal to 0, 1 or 2";
}
?>


Heyyo


<?php if ($a == 5): ?>
A is equal to 5
<?php endif; ?>

<?php
if ($a == 5):
    echo "a equals 5";
    echo "...";
elseif ($a == 6):
    echo "a equals 6";
    echo "!!!";
else:
    echo "a is neither 5 nor 6";
endif;
?>



<?php
/**
 * Define MyClass
 */
class MyClassA
{
    public $public = 'Public';
    protected $protected = 'Protected';
    private $private = 'Private';

    function printHello()
    {
        echo $this->public;
        echo $this->protected;
        echo $this->private;
    }
}

$obj = new MyClassA();
echo $obj->public; // Works

$obj->printHello(); // Shows Public, Protected and Private


/**
 * Define MyClass2
 */
class MyClass2 extends MyClassA
{
    // We can redeclare the public and protected properties, but not private
    public $public = 'Public2';
    protected $protected = 'Protected2';

    function printHello()
    {
        echo $this->public;
        echo $this->protected;
        echo $this->private;
    }
}

$obj2 = new MyClass2();
echo $obj2->public; // Works
$obj2->printHello(); // Shows Public2, Protected2, Undefined

?>


<?php

$var = '';

// This will evaluate to TRUE so the text will be printed.
if (isset($var)) {
    echo "This var is set so I will print.";
}

// In the next examples we'll use var_dump to output
// the return value of isset().

$a = "test";
$b = "anothertest";

var_dump(isset($a));      // TRUE
var_dump(isset($a, $b)); // TRUE

unset ($a);

var_dump(isset($a));     // FALSE
var_dump(isset($a, $b)); // FALSE

$foo = NULL;
var_dump(isset($foo));   // FALSE

?>

<?php

$a = array ('test' => 1, 'hello' => NULL, 'pie' => array('a' => 'apple'));

var_dump(isset($a['test']));            // TRUE
var_dump(isset($a['foo']));             // FALSE
var_dump(isset($a['hello']));           // FALSE

// The key 'hello' equals NULL so is considered unset
// If you want to check for NULL key values then try: 
var_dump(array_key_exists('hello', $a)); // TRUE

// Checking deeper array values
var_dump(isset($a['pie']['a']));        // TRUE
var_dump(isset($a['pie']['b']));        // FALSE
var_dump(isset($a['cake']['a']['b']));  // FALSE

?>

