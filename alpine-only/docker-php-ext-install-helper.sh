#!/bin/ash

hook_prepare() {
  if [ -z "$PHPIZE_DEPS" ]; then
    return
  fi 

  apkDel=
  if apk info --installed .phpize-deps-configure > /dev/null; then
    apkDel='.phpize-deps-configure'
  elif ! apk info --installed .phpize-deps > /dev/null; then
    apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS
    apkDel='.phpize-deps'
  fi
}

hook_clean() {
  if [ -n "$apkDel" ]; then
    apk del $apkDel
  fi
  apk del .phpext-deps
}

install_libs() {
  apk add --no-cache --virtual .phpext-deps "$@"
}
