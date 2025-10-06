#!/usr/bin/env bash
set -Eeuo pipefail

declare -A aliases=(
	[8.4]='8 latest'
)

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'to_entries | map(if .value then .key | @sh else empty end) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

# sort version numbers with highest first
IFS=$'\n'; set -- $(sort -rV <<<"$*"); unset IFS

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	local copyPaths;
	(
		cd "$dir"
		IFS=" " read -r -a copyPaths <<< "$(git show HEAD:./Dockerfile | awk '
			BEGIN { ORS=" "; }
			toupper($1) == "COPY" {
				for (i = 2; i < NF; i++) {
					print $i
				}
			}
		')"
		fileCommit Dockerfile "${copyPaths[@]}"
	)
}

getArches() {
	local repo="$1"; shift
	local officialImagesBase="${BASHBREW_LIBRARY:-https://github.com/docker-library/official-images/raw/HEAD/library}/"

	local parentRepoToArchesStr
	parentRepoToArchesStr="$(
		find -name 'Dockerfile' -exec awk -v officialImagesBase="$officialImagesBase" '
				toupper($1) == "FROM" && $2 !~ /^('"$repo"'|scratch|.*\/.*)(:|$)/ {
					printf "%s%s\n", officialImagesBase, $2
				}
			' '{}' + \
			| sort -u \
			| xargs -r bashbrew cat --format '["{{ .RepoName }}:{{ .TagName }}"]="{{ join " " .TagEntry.Architectures }}"'
	)"
	eval "declare -g -A parentRepoToArches=( $parentRepoToArchesStr )"
}
getArches 'php'

cat <<-EOH
# this file is generated via https://github.com/docker-library/php/blob/$(fileCommit "$self")/$self

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit)
GitRepo: https://github.com/docker-library/php.git
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

for version; do
	rcVersion="${version%-rc}"
	export version rcVersion

	if ! fullVersion="$(jq -er '.[env.version] | if . then .version else empty end' versions.json)"; then
		continue
	fi

	if [ "$rcVersion" != "$version" ] && rcFullVersion="$(jq -er '.[env.rcVersion] | if . then .version else empty end' versions.json)"; then
		# if this is a "-rc" release, let's make sure the release it contains isn't already GA (and thus something we should not publish anymore)
		latestVersion="$({ echo "$fullVersion"; echo "$rcFullVersion"; } | sort -V | tail -1)"
		if [[ "$fullVersion" == "$rcFullVersion"* ]] || [ "$latestVersion" = "$rcFullVersion" ]; then
			# "x.y.z-rc1" == x.y.z*
			continue
		fi
	fi

	variants="$(jq -r '.[env.version].variants | map(@sh) | join(" ")' versions.json)"
	eval "variants=( $variants )"

	versionAliases=(
		$fullVersion
		$version
		${aliases[$version]:-}
	)

	defaultDebianVariant="$(jq -r '
		.[env.version].variants
		| map(
			split("/")[0]
			| select(
				startswith("alpine")
				| not
			)
		)
		| .[0]
	' versions.json)"
	defaultAlpineVariant="$(jq -r '
		.[env.version].variants
		| map(
			split("/")[0]
			| select(
				startswith("alpine")
			)
		)
		| .[0]
		# intl will not compile on Alpine 3.22 causing build failures for downstream images (joomla, mediawiki, wordpress): https://github.com/docker-library/php/issues/1585
		# since PHP 8.1 is EOL at the end of the year and wont likely get fixes, keep the default Alpine at 3.21
		| if env.version == "8.1" then
			"alpine3.21"
		else
			.
		end
	' versions.json)"

	for dir in "${variants[@]}"; do
		suite="$(dirname "$dir")" # "buster", etc
		variant="$(basename "$dir")" # "cli", etc
		dir="$version/$dir"
		[ -f "$dir/Dockerfile" ] || continue

		variantAliases=( "${versionAliases[@]/%/-$variant}" )
		variantAliases=( "${variantAliases[@]//latest-/}" )

		if [ "$variant" = 'cli' ]; then
			variantAliases+=( "${versionAliases[@]}" )
		fi

		suiteVariantAliases=( "${variantAliases[@]/%/-$suite}" )
		if [ "$suite" = "$defaultAlpineVariant" ] ; then
			variantAliases=( "${variantAliases[@]/%/-alpine}" )
		elif [ "$suite" != "$defaultDebianVariant" ]; then
			variantAliases=()
		fi
		variantAliases=( "${suiteVariantAliases[@]}" ${variantAliases[@]+"${variantAliases[@]}"} )
		variantAliases=( "${variantAliases[@]//latest-/}" )

		variantParent="$(awk 'toupper($1) == "FROM" { print $2 }' "$dir/Dockerfile")"
		variantArches="${parentRepoToArches[$variantParent]}"

		commit="$(dirCommit "$dir")"

		echo
		cat <<-EOE
			Tags: $(join ', ' "${variantAliases[@]}")
			Architectures: $(join ', ' $variantArches)
			GitCommit: $commit
			Directory: $dir
		EOE
	done
done
