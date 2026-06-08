#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

LUAROCKS_VERSION='3.13'
LUAROCKS_USE_PKGMAN='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --luarocks-version)
            LUAROCKS_VERSION="$2"
            shift
            ;;
        --luarocks-purge | --purge)
            LUAROCKS_PURGE='true'
            ;;
        --luarocks-pkgman | --pkgman)
            LUAROCKS_USE_PKGMAN='true'
            ;;
        --luarocks-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if ! [[ "$LUAROCKS_VERSION" =~ [0-9]+(\.[0-9]+)* ]]; then
    Plan::log.mod -c 1 "Invalid version format '$LUAROCKS_VERSION'"
    exit 1
elif [ "$LUAROCKS_USE_PKGMAN" != 'true' ]; then
    # Build versions use X.Y.Z format
    [[ "$LUAROCKS_VERSION" =~ [0-9]+\.[0-9]+ ]] \
        && LUAROCKS_VERSION+='.0'
fi

#
# Remove Install
#

if [ "$LUAROCKS_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging Luarocks'
    pkg_remove luarocks

    # Do this here since removal for builds is handled by make
    if [ "$LUAROCKS_USE_PKGMAN" ]; then
        sudo rm -f \
            /usr/bin/luarocks \
            /usr/local/bin/luarocks \
            "$(command -v luarocks || true)"
        if command -v luarocks; then
            Plan::log.mod -c 1 'Failed to purge Luarocks'
            exit 1
        fi
    fi
fi

# Check built installs in build script
if [ "$LUAROCKS_USE_PKGMAN" ] && command -v luarocks; then
    Plan::log.mod 'Skipping'
    Plan::vcache.add local LUAROCKS_SKIP_INSTALL true
    exit 0
fi

#
# Environment
#

Plan::vcache.add local LUAROCKS_VERSION "$LUAROCKS_VERSION"
Plan::vcache.add local LUAROCKS_USE_PKGMAN "$LUAROCKS_USE_PKGMAN"

Plan::log.mod ' '
