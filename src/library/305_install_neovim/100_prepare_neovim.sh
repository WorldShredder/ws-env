#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

NEOVIM_TAG=''
NEOVIM_COMMIT=''
NEOVIM_USE_PKGMAN='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --neovim-tag)
            NEOVIM_TAG="$2"
            shift
            ;;
        --neovim-commit)
            NEOVIM_COMMIT="$2"
            shift
            ;;
        --neovim-purge | --purge)
            NEOVIM_PURGE='true'
            ;;
        --neovim-pkgman | --pkgman)
            NEOVIM_USE_PKGMAN='true'
            ;;
        --neovim-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if [ -n "$NEOVIM_COMMIT" ] && ! [[ "$NEOVIM_COMMIT" =~ ^[a-f0-9]+$ ]]; then
    Plan::log.mod -c 1 "Invalid commit ID '$NEOVIM_COMMIT'"
    exit 1
fi

#
# Environment
#

Plan::vcache.add local NEOVIM_TAG "$NEOVIM_TAG"
Plan::vcache.add local NEOVIM_COMMIT "$NEOVIM_COMMIT"
Plan::vcache.add local NEOVIM_USE_PKGMAN "$NEOVIM_USE_PKGMAN"

#
# Remove Install
#

if [ "$NEOVIM_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging Neovim'

    pkg_remove neovim || true

    sudo rm -rf \
        '/usr/bin/nvim' \
        '/usr/local/bin/nvim' \
        '/usr/local/share/nvim' \
        '/usr/local/lib/nvim' \
        "$(command -v nvim 2> /dev/null || true)"

    if command -v nvim; then
        Plan::log.mod -c 1 'Failed to purge Neovim'
        exit 1
    fi
fi

if command -v nvim; then
    Plan::log.mod 'Skipping'
    Plan::vcache.add local NEOVIM_SKIP_INSTALL true
    exit 0
fi

Plan::log.mod ' '
