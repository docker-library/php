#!/bin/sh
set -e

# prefer user supplied CFLAGS, but default to our PHP_CFLAGS
: ${CFLAGS:=$PHP_CFLAGS}
: ${CPPFLAGS:=$PHP_CPPFLAGS}
: ${LDFLAGS:=$PHP_LDFLAGS}
export CFLAGS CPPFLAGS LDFLAGS

srcExists=
if [ -d /usr/src/php ]; then
	srcExists=1
fi
docker-php-source extract
if [ -z "$srcExists" ]; then
	touch /usr/src/php/.docker-delete-me
fi

cd /usr/src/php/ext

ext="$1"
if [ -z "$ext" ] || [ ! -d "$ext" ]; then
	echo >&2 "usage: $0 ext-name [configure flags]"
	echo >&2 "   ie: $0 gd --with-jpeg-dir=/usr/local/something"
	echo >&2
	echo >&2 'Possible values for ext-name:'
	find /usr/src/php/ext \
			-mindepth 2 \
			-maxdepth 2 \
			-type f \
			-name 'config.m4' \
		| xargs -n1 dirname \
		| xargs -n1 basename \
		| sort \
		| xargs
	exit 1
fi
shift

pm='unknown'
if [ -e /lib/apk/db/installed ]; then
	pm='apk'
fi

if [ "$pm" = 'apk' ]; then
	if \
		[ -n "$PHPIZE_DEPS" ] \
		&& ! apk info --installed .phpize-deps > /dev/null \
		&& ! apk info --installed .phpize-deps-configure > /dev/null \
	; then
		apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS
	fi
fi

if command -v dpkg-architecture > /dev/null; then
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
	set -- --build="$gnuArch" "$@"
fi

set -x
cd "$ext"
phpize
./configure "$@"
