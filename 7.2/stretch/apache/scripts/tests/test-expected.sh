#!/bin/bash
  
find /php/tests_ps -name '*.php' -type f | while read file
do
        echo TEST $file
        base=$(basename $file)
        diff <(/polyscripted-php/bin/php $file) /php/expected/$base
done

