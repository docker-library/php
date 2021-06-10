#!/usr/bin/env bash
set -Eeuo pipefail

# https://www.php.net/gpg-keys.php
declare -A gpgKeys=(
	# https://wiki.php.net/todo/php81
	# krakjoe & ramsey & patrickallaert
	# https://www.php.net/gpg-keys.php#gpg-8.1
	[8.1]='528995BFEDFBA7191D46839EF9BA0ADA31CBD89E 39B641343D8C104B2B146DC3F9C39DC0B9698544 F1F692238FBC1666E5A5CCD4199F9DFEF6FFBAFD'

	# https://wiki.php.net/todo/php80
	# pollita & carusogabriel
	# https://www.php.net/gpg-keys.php#gpg-8.0
	[8.0]='1729F83938DA44E27BA0F4D3DBDB397470D12172 BFDDD28642824F8118EF77909B67A5C12229118F'

	# https://wiki.php.net/todo/php74
	# petk & derick
	# https://www.php.net/gpg-keys.php#gpg-7.4
	[7.4]='42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312'

	# https://wiki.php.net/todo/php73
	# cmb & stas
	# https://www.php.net/gpg-keys.php#gpg-7.3
	[7.3]='CBAF69F173A0FEA4B537F470D66C9593118BCCB6 F38252826ACD957EF380D39F2F7956BC5DA04B5D'

	# https://wiki.php.net/todo/php72
	# pollita & remi
	# https://www.php.net/downloads.php#gpg-7.2
	# https://www.php.net/gpg-keys.php#gpg-7.2
	[7.2]='1729F83938DA44E27BA0F4D3DBDB397470D12172 B1B44D8F021E4E2D6021E995DC9FF8D3EE5AF27F'
)
# see https://www.php.net/downloads.php

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
			.releases[]
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
		echo >&2
		echo >&2 "error: unable to determine available releases of $version"
		echo >&2
		exit 1
	fi

	# format of "possibles" array entries is "VERSION URL.TAR.XZ URL.TAR.XZ.ASC SHA256" (each value shell quoted)
	#   see the "apiJqExpr" values above for more details
	eval "possi=( ${possibles[0]} )"
	fullVersion="${possi[0]}"
	url="${possi[1]}"
	ascUrl="${possi[2]}"
	sha256="${possi[3]}"

	gpgKey="${gpgKeys[$rcVersion]:-}"
	if [ -z "$gpgKey" ]; then
		echo >&2 "ERROR: missing GPG key fingerprint for $version"
		echo >&2 "  try looking on https://www.php.net/downloads.php#gpg-$rcVersion"
		echo >&2 "  (and update 'gpgKeys' array in '$BASH_SOURCE')"
		exit 1
	fi

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
		buster \
		stretch \
		alpine3.13 \
		alpine3.12 \
	; do
		for variant in cli apache fpm zts; do
			[ -d "$version/$suite/$variant" ] || continue
			export suite variant
			variants="$(jq <<<"$variants" -c '. + [ env.suite + "/" + env.variant ]')"
		done
	done

	echo "$version: $fullVersion"

	if [ "$fullVersion" = '8.0.2' ]; then
		# https://bugs.php.net/bug.php?id=80711#1612456954 😬
		url+='?a=1'
		ascUrl+='?a=1'
	fi

	export fullVersion url ascUrl sha256 gpgKey
	json="$(
		jq <<<"$json" -c \
			--argjson variants "$variants" \
			'.[env.version] = {
				version: env.fullVersion,
				url: env.url,
				ascUrl: env.ascUrl,
				sha256: env.sha256,
				gpgKeys: env.gpgKey,
				variants: $variants,
			}'
	)"
done

jq <<<"$json" -S . > versions.json
