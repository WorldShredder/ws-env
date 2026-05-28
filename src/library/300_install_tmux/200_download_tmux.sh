#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$TMUX_SKIP_INSTALL" = 'true' ] || [ "$TMUX_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Download Source
#

Plan::vcache.add -s local TMUX_DL_PATH "${PLAN__PATH_CACHE}/tmux"
rm -rf "$TMUX_DL_PATH"

if [ -n "$TMUX_TAG" ]; then
    Plan::log.mod "Downloading from tag '$TMUX_TAG'"
    WSE::git_download 'tmux/tmux' -t "$TMUX_TAG" -o "$TMUX_DL_PATH"
else
    Plan::log.mod "Downloading commit '${TMUX_COMMIT:-latest}'"
    WSE::git_download 'tmux/tmux' -c "$TMUX_COMMIT" -o "$TMUX_DL_PATH"
fi

Plan::log.mod ' '
