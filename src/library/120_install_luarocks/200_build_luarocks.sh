#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$LUAROCKS_SKIP_INSTALL" = 'true' ] || [ "$LUAROCKS_USE_PKGMAN" = 'true' ]; then
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

Plan::log.mod "Downloading v${LUAROCKS_VERSION}"
Plan::vcache.add -s local LUAROCKS_DL_NAME "luarocks-${LUAROCKS_VERSION}"
cd "${PLAN__PATH_CACHE}"
curl -fLRO "https://luarocks.org/releases/${LUAROCKS_DL_NAME}.tar.gz"

Plan::log.mod "Decompressing '${LUAROCKS_DL_NAME}.tar.gz'"
tar xzpf "${LUAROCKS_DL_NAME}.tar.gz"
cd "$LUAROCKS_DL_NAME"

#
# Remove Install
#

if [ "$LUAROCKS_PURGE" = 'true' ]; then
    Plan::log.mod 'Attempting to purge Luarocks build'
    sudo make uninstall || true
fi

if command -v luarocks; then
    if [ "$LUAROCKS_PURGE" = 'true' ]; then
        Plan::log.mod -c 1 'Failed to purge Luarocks'
        exit 1
    fi
    Plan::log.mod 'Skipping'
    Plan::vcache.add local LUAROCKS_SKIP_INSTALL true
    exit 0
fi

#
# Build Binary
#

Plan::log.mod 'Configuring make'
./configure

Plan::log.mod "Building v${LUAROCKS_VERSION}"
make

Plan::log.mod ' '
