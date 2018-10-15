<?php
$a = 1; /* global scope */ 

function test()
{ 
    echo $a; /* reference to local scope variable */ 
} 

test();
?>
