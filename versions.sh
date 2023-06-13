#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
	json='{}'
else
	json="$(< versions.json)"
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	rcVersion="${version%-rc}"
	export version rcVersion

	# scrape the relevant API based on whether we're looking for pre-releases
	if [ "$rcVersion" = "$version" ]; then
		apiUrl="https://www.php.net/releases/index.php?json&max=100&version=${rcVersion%%.*}"
		apiJqExpr='
			(keys[] | select(startswith(env.rcVersion))) as $version
			| [ $version, (
				.[$version].source[]
				| select(.filename | endswith(".xz"))
				|
					"https://www.php.net/distributions/" + .filename,
					"https://www.php.net/distributions/" + .filename + ".asc",
					.sha256 // ""
			) ]
		'
	else
		apiUrl='https://qa.php.net/api.php?type=qa-releases&format=json'
		apiJqExpr='
			(.releases // [])[]
			| select(.version | startswith(env.rcVersion))
			| [
				.version,
				.files.xz.path // "",
				"",
				.files.xz.sha256 // ""
			]
		'
	fi
	IFS=$'\n'
	possibles=( $(
		curl -fsSL "$apiUrl" \
			| jq --raw-output "$apiJqExpr | @sh" \
			| sort -rV
	) )
	unset IFS

	if [ "${#possibles[@]}" -eq 0 ]; then
		if [ "$rcVersion" = "$version" ]; then
			echo >&2
			echo >&2 "error: unable to determine available releases of $version"
			echo >&2
			exit 1
		else
			echo >&2 "warning: skipping/removing '$version' (does not appear to exist upstream)"
			json="$(jq <<<"$json" -c '.[env.version] = null')"
			continue
		fi
	fi

	# format of "possibles" array entries is "VERSION URL.TAR.XZ URL.TAR.XZ.ASC SHA256" (each value shell quoted)
	#   see the "apiJqExpr" values above for more details
	eval "possi=( ${possibles[0]} )"
	fullVersion="${possi[0]}"
	url="${possi[1]}"
	ascUrl="${possi[2]}"
	sha256="${possi[3]}"

	if ! wget -q --spider "$url"; then
		echo >&2 "error: '$url' appears to be missing"
		exit 1
	fi

	# if we don't have a .asc URL, let's see if we can figure one out :)
	if [ -z "$ascUrl" ] && wget -q --spider "$url.asc"; then
		ascUrl="$url.asc"
	fi

	variants='[]'
	# order here controls the order of the library/ file
	for suite in \
		bookworm \
		bullseye \
		buster \
		alpine3.18 \
		alpine3.17 \
		alpine3.16 \
	; do
		# https://github.com/docker-library/php/pull/1348
		if [ "$rcVersion" = '8.0' ] && [[ "$suite" = alpine* ]] && [ "$suite" != 'alpine3.16' ]; then
			continue
		fi
		# 8.0 doesn't support OpenSSL 3, which is the only version in bookworm
		# only keep two variants of Debian per version of php
		if [ "$rcVersion" = '8.0' ] && [ "$suite" = 'bookworm' ]; then
			continue
		elif [ "$rcVersion" != '8.0' ] && [ "$suite" = 'buster' ]; then
			continue
		fi
		# https://github.com/docker-library/php/pull/1405
		# 8.1 is temporary: https://github.com/docker-library/official-images/pull/14735 (should remove Alpine 3.16 support once Nextcloud 25 is EOL ~Oct 2023)
		if [ "$suite" = 'alpine3.16' ] && [ "$rcVersion" != '8.0' ] && [ "$rcVersion" != '8.1' ]; then
			continue
		fi
		for variant in cli apache fpm zts; do
			if [[ "$suite" = alpine* ]]; then
				if [ "$variant" = 'apache' ]; then
					continue
				fi
			fi
			export suite variant
			variants="$(jq <<<"$variants" -c '. + [ env.suite + "/" + env.variant ]')"
		done
	done

	echo "$version: $fullVersion"

	export fullVersion url ascUrl sha256
	json="$(
		jq <<<"$json" -c --argjson variants "$variants" '
			.[env.version] = {
				version: env.fullVersion,
				url: env.url,
				ascUrl: env.ascUrl,
				sha256: env.sha256,
				variants: $variants,
			}
		'
	)"

	if [ "$version" = "$rcVersion" ]; then
		json="$(jq <<<"$json" -c '
			.[env.version + "-rc"] //= null
		')"
	fi
done

jq <<<"$json" -S . > versions.json
