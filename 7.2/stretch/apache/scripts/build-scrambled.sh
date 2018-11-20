#!/bin/bash

cd $POLYSCRIPT_PATH

./php-scrambler
if [ -f ./scrambled.json ]; then 
        s_php tok-php-transformer.php -p "$PHP_SRC_PATH"ext/phar --replace --inc --phar
        cd $PHP_SRC_PATH
        make install -k
else 
        exit 1
fi

cd $POLYSCRIPT_PATH
s_php tok-php-transformer.php -p "$PHP_SRC_PATH"ext/phar/phar.php --replace
cd $PHP_SRC_PATH
make pharcmd -k
