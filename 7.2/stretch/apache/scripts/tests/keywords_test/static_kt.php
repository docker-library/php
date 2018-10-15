<?php
function foo(){
    static $int = 0;          // correct 
    static $int = 1+2;        // correct (as of PHP 5.6)

    $int++;
    echo $int;
}
?>
