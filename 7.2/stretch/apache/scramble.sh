#!/bin/bash

if [ "$MODE" == "poly" ] 
then
	echo "SCRAM"
	cd $POLYSCRIPT_PATH
	./build-scrambled.sh
	s_php tok-php-transformer.php -p /usr/src/wordpress --replace
	rm -rf /usr/bin/s_php
fi
