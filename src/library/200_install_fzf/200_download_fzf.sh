#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$FZF_SKIP_INSTALL" = 'true' ] || [ "$FZF_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Download Source
#

Plan::vcache.add -s local FZF_DL_PATH "${PLAN__PATH_CACHE}/fzf"
rm -rf "$FZF_DL_PATH"

if [ -n "$FZF_TAG" ]; then
    Plan::log.mod "Downloading from tag '$FZF_TAG'"
    WSE::git_download 'junegunn/fzf' -t "$FZF_TAG" -o "$FZF_DL_PATH"
else
    Plan::log.mod "Downloading commit '${FZF_COMMIT:-latest}'"
    WSE::git_download 'junegunn/fzf' -c "$FZF_COMMIT" -o "$FZF_DL_PATH"
fi

Plan::log.mod ' '
