#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# TODO consume https://www.php.net/releases/branches.php and https://www.php.net/release-candidates.php?format=json here like in Go, Julia, etc (so we can have a canonical "here's all the versions possible" mode, and more automated metadata like EOL 👀)

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
		apiUrl='https://www.php.net/release-candidates.php?format=json'
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
		echo >&2 "warning: skipping/removing '$version' (does not appear to exist upstream)"
		json="$(jq <<<"$json" -c '.[env.version] = null')"
		continue
	fi

	# format of "possibles" array entries is "VERSION URL.TAR.XZ URL.TAR.XZ.ASC SHA256" (each value shell quoted)
	#   see the "apiJqExpr" values above for more details
	eval "possi=( ${possibles[0]} )"
	fullVersion="${possi[0]}"
	url="${possi[1]}"
	ascUrl="${possi[2]}"
	sha256="${possi[3]}"

	if ! curl --head -fsSL "$url" -o /dev/null; then
		echo >&2 "error: '$url' appears to be missing"
		exit 1
	fi

	# if we don't have a .asc URL, let's just assume one :)
	if [ -z "$ascUrl" ]; then
		ascUrl="$url.asc"
	fi

	variants='[]'
	# order here controls the order of the library/ file
	for suite in \
		trixie \
		bookworm \
		alpine3.22 \
		alpine3.21 \
	; do
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

	# make sure RCs and releases have corresponding pairs
	json="$(jq <<<"$json" -c '
		.[
			env.version
			+ if env.version == env.rcVersion then
				"-rc"
			else "" end
		] //= null
	')"
done

jq <<<"$json" 'to_entries | sort_by(.key) | from_entries' > versions.json
