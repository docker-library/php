#!/bin/bash
set -e

declare -A gpgKeys
gpgKeys=(
	[5.5]='0BD78B5F97500D450838F95DFE857D9A90D90EC1 0B96609E270F565C13292B24C13C70B87267B52D'
)
# see http://php.net/downloads.php

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

packagesUrl='http://php.net/releases/index.php?serialize=1&version=5'
packages="$(echo "$packagesUrl" | sed -r 's/[^a-zA-Z.-]+/-/g')"
curl -sSL "${packagesUrl}" > "$packages"

for version in "${versions[@]}"; do
	fullVersion="$(sed -r 's/.*"filename";s:[0-9]+:"php-([^"]+)\.tar\.bz2".*/\1/' $packages)"
	gpgKey="${gpgKeys[$version]}"
	if [ -z "$gpgKey" ]; then
		echo >&2 "ERROR: missing GPG key fingerprint for $version"
		echo >&2 "  try looking on http://php.net/downloads.php#gpg-$version"
		exit 1
	fi
	
	insert="$(cat "Dockerfile-apache-insert" | sed 's/[\]/\\&/g')"
	(
		set -x
		sed -ri '
			s/^(ENV PHP_VERSION) .*/\1 '"$fullVersion"'/;
			s/^(RUN gpg .* --recv-keys) [0-9a-fA-F ]*$/\1 '"$gpgKey"'/
		' "$version/Dockerfile"
		
		awk -vf2="$insert" '/^\t&& make install \\$/{print f2;next}1' "$version/Dockerfile" "Dockerfile-apache-tail" > "$version/apache/Dockerfile"
	)
done

rm "$packages"
