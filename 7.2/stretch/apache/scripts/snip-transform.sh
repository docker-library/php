#!/bin/bash

if [ -f /php/scrambled.json ]; then     
	out="$(/php/php /php/tok-php-transformer.php -s "$SNIP")"
	echo "$out"
else
        echo "$SNIP"
fi

