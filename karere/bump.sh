#!/usr/bin/env bash
# Usage: karere/bump.sh <version>   (./update passes nvchecker's version)
#
# Bump karere and sync the pinned CEF runtime with it. Each release builds against
# a Karere-patched CEF (custom release on tobagin/karere); its tag, version and
# sha256 are read from upstream's Flatpak manifest at the target tag, so a release
# that moves to a new CEF can't be built against the old one.
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

repo='tobagin/karere'
manifest='packaging/io.github.tobagin.karere.yml'

ver="${1:?usage: bump.sh <version>}"
ver="${ver#v}"
[[ $ver =~ ^[0-9]+(\.[0-9]+)+$ ]] || { echo "bad version: '$ver'" >&2; exit 1; }

# x86_64 CEF archive: "url: ..._linux64_minimal.zip" followed by "sha256: ..."
read -r cefurl cefsha < <(
	curl -fsSL "https://raw.githubusercontent.com/$repo/v$ver/$manifest" |
		awk '/url:.*_linux64_minimal\.zip/ { u = $2; getline; print u, $2; exit }'
) || true
[[ ${cefurl-} == */releases/download/*/cef_binary_*_linux64_minimal.zip && ${cefsha-} =~ ^[0-9a-f]{64}$ ]] ||
	{ echo "could not parse CEF pin from $manifest at v$ver" >&2; exit 1; }

ceftag="${cefurl#*/releases/download/}"
ceftag="${ceftag%%/*}"
cefver="${cefurl##*/cef_binary_}"
cefver="${cefver%_linux64_minimal.zip}"
cefver="${cefver//%2B/+}"

srcsha=$(curl -fsSL "https://github.com/$repo/archive/refs/tags/v$ver.tar.gz" | sha256sum | cut -d' ' -f1)

sed -i -E \
	-e "s|^pkgver=.*|pkgver=$ver|" \
	-e "s|^pkgrel=.*|pkgrel=1|" \
	-e "s|^_ceftag=.*|_ceftag='$ceftag'|" \
	-e "s|^_cefver=.*|_cefver='$cefver'|" \
	-e "/^sha256sums=\(/,/^\)/c\\sha256sums=(\n\t'$srcsha'\n\t'$cefsha'\n)" \
	PKGBUILD

echo "karere -> $ver (CEF $cefver, $ceftag)"
