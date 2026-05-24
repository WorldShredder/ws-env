#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

LUAROCKS_VERSION='3.13'
LUAROCKS_USE_PKGMAN='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --luarocks-version)
            LUA_LUAROCKS_VERSION="$2"
            shift
            ;;
        --luarocks-purge)
            LUA_PURGE='true'
            ;;
        --luarocks-use-pkgman)
            LUA_USE_PKGMAN='true'
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
    # Purge build in build script
    [ "$LUAROCKS_USE_PKGMAN" != 'true' ] \
        && Plan::vcache.add local LUAROCKS_PURGE true
fi

# Check built installs in build script
if [ "$LUAROCKS_USE_PKGMAN" ] && command -v lua; then
    Plan::log.mod 'Skipping'
    Plan::vcache.add local LUA_SKIP_INSTALL true
    exit 0
fi

#
# Environment
#

if [ "$WSE__DISTRIB" = 'fedora' ] && [ "$LUA_USE_PKGMAN" = 'true' ]; then
    # Fedora package is 'lua'
    LUA_VERSION=''
fi

Plan::vcache.add local LUA_VERSION "$LUA_VERSION"
Plan::vcache.add local LUA_USE_PKGMAN "$LUA_USE_PKGMAN"

Plan::log.mod ' '
