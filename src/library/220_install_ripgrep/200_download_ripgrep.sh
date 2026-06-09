#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$RIPGREP_SKIP_INSTALL" = 'true' ] || [ "$RIPGREP_USE_PKGMAN" = 'true' ] || [ -n "$RIPGREP_VERSION" ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Download Source
#

Plan::vcache.add -s local RIPGREP_DL_PATH "${PLAN__PATH_CACHE}/ripgrep"
rm -rf "$RIPGREP_DL_PATH"

if [ -n "$RIPGREP_TAG" ]; then
    Plan::log.mod "Downloading from tag '$RIPGREP_TAG'"
    WSE::git_download 'BurntSushi/ripgrep' -t "$RIPGREP_TAG" -o "$RIPGREP_DL_PATH"
elif [ -z "$RIPGREP_VERSION" ]; then
    Plan::log.mod "Downloading commit '${RIPGREP_COMMIT:-latest}'"
    WSE::git_download 'BurntSushi/ripgrep' -c "$RIPGREP_COMMIT" -o "$RIPGREP_DL_PATH"
fi

Plan::log.mod ' '
