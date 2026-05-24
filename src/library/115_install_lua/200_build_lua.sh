#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$LUA_SKIP_INSTALL" = 'true' ] || [ "$LUA_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

if ! command -v gcc; then
    Plan::log.mod 'Installing gcc'
    pkg_install gcc
fi

#
# Download Source
#

Plan::log.mod "Downloading v${LUA_VERSION}"
cd "${PLAN__PATH_CACHE}"
lua_name="lua-${LUA_VERSION}"
curl -fLRO "https://lua.org/ftp/${lua_name}.tar.gz"

Plan::log.mod "Decompressing '${lua_name}.tar.gz'"
tar xzpf "${lua_name}.tar.gz"
cd "$lua_name"

#
# Remove Install
#

if [ "$LUA_PURGE" = 'true' ]; then
    Plan::log.mod 'Attempting to purge Lua build'
    sudo make uninstall || true
fi

if command -v lua; then
    if [ "$LUA_PURGE" = 'true' ]; then
        Plan::log.mod -c 1 'Failed to purge Lua'
        exit 1
    fi
    Plan::log.mod 'Skipping'
    Plan::vcache.add local LUA_SKIP_INSTALL true
    exit 0
fi

#
# Build Binary
#

Plan::log.mod 'Building binaries'
make all test

Plan::log.mod ' '
