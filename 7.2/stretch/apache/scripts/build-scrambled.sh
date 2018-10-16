#!/bin/bash

if [ ! -f "$PATH/s_php" ]; then
        cp /usr/local/bin/php /usr/local/bin/s_php
fi

./php-scrambler

s_php tok-php-transformer.php -p "$PHP_SRC_PATH"ext/phar --replace --inc --phar

cd $PHP_SRC_PATH
make install -k

cd $POLYSCRIPT_PATH
s_php tok-php-transformer.php -p "$PHP_SRC_PATH"ext/phar/phar.php --replace
cd $PHP_SRC_PATH
make install -k
