#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$SESH_SKIP_INSTALL" = 'true' ] || [ "$SESH_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Download Source
#

Plan::vcache.add -s local SESH_DL_PATH "${PLAN__PATH_CACHE}/sesh"
rm -rf "$SESH_DL_PATH"

repo_name='joshmedeski/sesh'

if [ -n "$SESH_TAG" ]; then
    Plan::log.mod "Downloading from tag '$SESH_TAG'"
    WSE::git_download "$repo_name" -t "$SESH_TAG" -o "$SESH_DL_PATH"
else
    Plan::log.mod "Downloading commit '${SESH_COMMIT:-latest}'"
    WSE::git_download "$repo_name" -c "$SESH_COMMIT" -o "$SESH_DL_PATH"
fi

Plan::log.mod ' '
