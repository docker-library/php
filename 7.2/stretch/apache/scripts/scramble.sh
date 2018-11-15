#!/bin/bash

if [ ! -f "$PATH/s_php" ]; then
        cp /usr/local/bin/php /usr/local/bin/s_php
fi


if [ "$MODE" == "poly" ] 
then
	echo "SCRAM"
	cd $POLYSCRIPT_PATH
	./build-scrambled.sh
	s_php tok-php-transformer.php -p /usr/src/wordpress --replace
fi

