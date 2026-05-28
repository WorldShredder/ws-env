#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

TMUX_TAG=''
TMUX_COMMIT=''
TMUX_USE_PKGMAN='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --tmux-tag)
            TMUX_TAG="$2"
            shift
            ;;
        --tmux-commit)
            TMUX_COMMIT="$2"
            shift
            ;;
        --tmux-purge | --purge)
            TMUX_PURGE='true'
            ;;
        --tmux-use-pkgman | --pkgman)
            TMUX_USE_PKGMAN='true'
            ;;
        --tmux-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if [ -n "$TMUX_COMMIT" ] && ! [[ "$TMUX_COMMIT" =~ ^[a-f0-9]+$ ]]; then
    Plan::log.mod -c 1 "Invalid commit ID '$TMUX_COMMIT'"
    exit 1
fi

#
# Environment
#

Plan::vcache.add local TMUX_TAG "$TMUX_TAG"
Plan::vcache.add local TMUX_COMMIT "$TMUX_COMMIT"
Plan::vcache.add local TMUX_USE_PKGMAN "$TMUX_USE_PKGMAN"

#
# Remove Install
#

if [ "$TMUX_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging Tmux'

    pkg_remove tmux || true

    sudo rm -rf \
        '/usr/bin/tmux' \
        '/usr/local/bin/tmux' \
        "$(command -v tmux 2> /dev/null || true)"

    if command -v tmux; then
        Plan::log.mod -c 1 'Failed to purge Tmux'
        exit 1
    fi
fi

if command -v tmux; then
    Plan::log.mod 'Skipping'
    Plan::vcache.add local TMUX_SKIP_INSTALL true
    exit 0
fi

Plan::log.mod ' '
