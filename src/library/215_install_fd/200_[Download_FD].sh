#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$FD_SKIP_INSTALL" = 'true' ] || [ "$FD_USE_PKGMAN" = 'true' ] || [ -n "$FD_VERSION" ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Download Source
#

Plan::vcache.add -s local FD_DL_PATH "${PLAN__PATH_CACHE}/fd"
rm -rf "$FD_DL_PATH"

if [ -n "$FD_TAG" ]; then
    Plan::log.mod "Downloading from tag '$FD_TAG'"
    WSE::git_download 'sharkdp/fd' -t "$FD_TAG" -o "$FD_DL_PATH"
else
    Plan::log.mod "Downloading commit '${FD_COMMIT:-latest}'"
    WSE::git_download 'sharkdp/fd' -c "$FD_COMMIT" -o "$FD_DL_PATH"
fi

Plan::log.mod ' '
