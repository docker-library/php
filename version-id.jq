def version_id:
	# https://www.php.net/phpversion
	# $version_id = $major_version * 10000 + $minor_version * 100 + $release_version;
	sub("[a-zA-Z].*$"; "")
	| split(".")
	| (
		(.[0] // 0 | tonumber) * 10000
		+ (.[1] // 0 | tonumber) * 100
		+ (.[2] // 0 | tonumber)
	)
;
