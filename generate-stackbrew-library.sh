#!/bin/bash
set -e

declare -A aliases
aliases=(
	[5.6]='5'
	[7.0]='7 latest'
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
url='git://github.com/docker-library/php'

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'

for version in "${versions[@]}"; do
	commit="$(cd "$version" && git log -1 --format='format:%H' -- Dockerfile $(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' Dockerfile))"
	fullVersion="$(grep -m1 'ENV PHP_VERSION ' "$version/Dockerfile" | cut -d' ' -f3)"
	versionAliases=( $fullVersion $version ${aliases[$version]} )
	
	echo
	for va in "${versionAliases[@]}"; do
		if [ "$va" = 'latest' ]; then
			va='cli'
		else
			va="$va-cli"
		fi
		echo "$va: ${url}@${commit} $version"
	done
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit} $version"
	done
	
	for variant in \
		alpine \
		apache \
		fpm fpm/alpine \
		zts zts/alpine \
	; do
		[ -e "$version/$variant/Dockerfile" ] || continue
		commit="$(cd "$version/$variant" && git log -1 --format='format:%H' -- Dockerfile $(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' Dockerfile))"
		slash='/'
		variantTag="${variant//$slash/-}"
		echo
		for va in "${versionAliases[@]}"; do
			if [ "$va" = 'latest' ]; then
				va="$variantTag"
			else
				va="$va-$variantTag"
			fi
			echo "$va: ${url}@${commit} $version/$variant"
		done
	done
done
