#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

LUA_VERSION='5.5'
LUA_USE_PKGMAN='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --lua-version)
            LUA_VERSION="$2"
            shift
            ;;
        --lua-purge)
            LUA_PURGE='true'
            ;;
        --lua-use-pkgman)
            LUA_USE_PKGMAN='true'
            ;;
        --lua-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if ! [[ "$LUA_VERSION" =~ [0-9]+(\.[0-9]+)* ]]; then
    Plan::log.mod -c 1 "Invalid version format '$LUA_VERSION'"
    exit 1
elif [ "$LUA_USE_PKGMAN" != 'true' ]; then
    # Build versions use X.Y.Z format
    [[ "$LUA_VERSION" =~ [0-9]+\.[0-9]+ ]] \
        && LUA_VERSION+='.0'
fi

#
# Remove Install
#

if [ "$LUA_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging Lua'
    declare -a remove_targets
    case "$WSE__DISTRIB" in
        debian) remove_targets+=(
            "lua${LUA_VERSION}" 'lua5.5' 'lua5.4' 'lua5.3' 'lua5.2' 'lua5.1'
        ) ;;
        fedora) remove_targets+=('lua') ;;
    esac

    # Some lua packages may not exist and cause failure
    for pkg in "${remove_targets[@]}"; do
        pkg_remove "$pkg" || true
    done

    if [ "$LUA_USE_PKGMAN" ]; then
        sudo rm -f /usr/bin/lua /usr/local/bin/lua "$(command -v lua || true)"
        if command -v lua; then
            Plan::log.mod -c 1 'Failed to purge Lua'
            exit 1
        fi
    fi
fi

# Check built installs in build script
if [ "$LUA_USE_PKGMAN" = 'true' ] && command -v lua; then
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
Plan::vcache.add local LUA_PURGE "$LUA_PURGE"

Plan::log.mod ' '
