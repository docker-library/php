#!/bin/bash

cp /php/resetPhp/zend_language_parser.y /php/php-src/Zend/
cp /php/resetPhp/zend_language_scanner.l /php/php-src/Zend/

if [[ $1 == "-revert" ]]; then
	
	rm -rf /php/tests-ps
	
	cd /php/php-src/
        make install
fi
