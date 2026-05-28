#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$NEOVIM_SKIP_INSTALL" = 'true' ] || [ "$NEOVIM_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Download Source
#

Plan::vcache.add -s local NEOVIM_DL_PATH "${PLAN__PATH_CACHE}/neovim"
rm -rf "$NEOVIM_DL_PATH"

repo_name='neovim/neovim'

if [ -n "$NEOVIM_TAG" ]; then
    Plan::log.mod "Downloading from tag '$NEOVIM_TAG'"
    WSE::git_download "$repo_name" -t "$NEOVIM_TAG" -o "$NEOVIM_DL_PATH"
else
    Plan::log.mod "Downloading commit '${NEOVIM_COMMIT:-latest}'"
    WSE::git_download "$repo_name" -c "$NEOVIM_COMMIT" -o "$NEOVIM_DL_PATH"
fi

Plan::log.mod ' '
