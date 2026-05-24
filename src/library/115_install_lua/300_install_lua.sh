#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$LUA_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

if [ "$LUA_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing ${WSE__DISTRIB} package v${LUA_VERSION}"
    case "$WSE__DISTRIB" in
        debian) pkg_install "lua${LUA_VERSION}" ;;
        fedora) pkg_install lua ;;
        *) exit 1 ;;
    esac
else
    Plan::log.mod "Installing v${LUA_VERSION}"
    cd "${PLAN__PATH_CACHE}/lua-${LUA_VERSION}"
    sudo make install
fi

Plan::log.mod ' '
