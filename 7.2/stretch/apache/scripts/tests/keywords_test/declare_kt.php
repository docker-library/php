<?php
function handler(){
    print "hello <br />";
}

register_tick_function("handler");

declare(ticks = 1){
    $b = 2;
} //closing curly bracket tickable
?>
