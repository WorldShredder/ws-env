#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$EZA_SKIP_INSTALL" = 'true' ] || [ "$EZA_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Download Source
#

Plan::vcache.add -s local EZA_DL_PATH "${PLAN__PATH_CACHE}/eza"
rm -rf "$EZA_DL_PATH"

if [ -n "$EZA_TAG" ]; then
    Plan::log.mod "Downloading from tag '$EZA_TAG'"
    WSE::git_download 'eza-community/eza' -t "$EZA_TAG" -o "$EZA_DL_PATH"
else
    Plan::log.mod "Downloading commit '${EZA_COMMIT:-latest}'"
    WSE::git_download 'eza-community/eza' -c "$EZA_COMMIT" -o "$EZA_DL_PATH"
fi

Plan::log.mod ' '
