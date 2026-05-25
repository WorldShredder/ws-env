#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$LUAROCKS_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

if [ "$LUAROCKS_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via ${WSE__DISTRIB} package manager"
    pkg_install luarocks
else
    Plan::log.mod "Installing v${LUA_VERSION}"
    cd "${PLAN__PATH_CACHE}/${LUAROCKS_DL_NAME}"
    sudo make install
    cd ..
    rm -rf "${LUAROCKS_DL_NAME}"{,.tar.gz}
fi

Plan::log.mod ' '
