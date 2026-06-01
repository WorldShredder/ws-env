#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

#
# Download Source
#

Plan::vcache.add -s local DOTFILES_DL_PATH "${PLAN__PATH_CACHE}/dotfiles"
rm -rf "$DOTFILES_DL_PATH"

if [ -n "$DOTFILES_TAG" ]; then
    Plan::log.mod "Downloading from tag '$DOTFILES_TAG'"
    WSE::git_download 'worldshredder/dotfiles' \
        -t "$DOTFILES_TAG" -o "$DOTFILES_DL_PATH"
else
    Plan::log.mod "Downloading commit '${DOTFILES_COMMIT:-latest}'"
    WSE::git_download 'worldshredder/dotfiles' \
        -c "$DOTFILES_COMMIT" -o "$DOTFILES_DL_PATH"
fi

Plan::log.mod ' '
