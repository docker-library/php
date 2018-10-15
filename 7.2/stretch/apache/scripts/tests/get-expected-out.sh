#!/bin/bash
  
rm -rf /php/expected
mkdir /php/expected

find /php/tests -name '*.php' -type f | while read file
do
        base=$(basename $file)
        /polyscripted-php/bin/php $file > "/php/expected/$base"
done


