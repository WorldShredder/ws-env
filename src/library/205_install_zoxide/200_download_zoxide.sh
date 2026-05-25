#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$ZOXIDE_SKIP_INSTALL" = 'true' ] || [ "$ZOXIDE_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Download Source
#

Plan::vcache.add -s local ZOXIDE_DL_PATH "${PLAN__PATH_CACHE}/zoxide"
rm -rf "$ZOXIDE_DL_PATH"

if [ -n "$ZOXIDE_TAG" ]; then
    Plan::log.mod "Downloading from tag '$ZOXIDE_TAG'"
    WSE::git_download 'ajeetdsouza/zoxide' -t "$ZOXIDE_TAG" -o "$ZOXIDE_DL_PATH"
else
    Plan::log.mod "Downloading commit '${ZOXIDE_COMMIT:-latest}'"
    WSE::git_download 'ajeetdsouza/zoxide' -c "$ZOXIDE_COMMIT" -o "$ZOXIDE_DL_PATH"
fi

Plan::log.mod ' '
