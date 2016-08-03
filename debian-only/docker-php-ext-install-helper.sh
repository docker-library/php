#!/bin/bash
buildDeps=()

hook_prepare() {
  apt-get update
}

hook_clean() {
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false "${buildDeps[@]}"
  rm -rf /var/lib/apt/lists/*
}

install_libs() {
  local d
  local deps=()
  for d; do
    if [[ ! " ${buildDeps[@]} " =~ " $d " ]]; then
      deps+=($d)
    fi
  done
    
  if [ ${#deps[@]} -eq 0 ]; then
    return
  fi

  apt-get install -yqq "${deps[@]}"
  buildDeps+=("${deps[@]}")
}
