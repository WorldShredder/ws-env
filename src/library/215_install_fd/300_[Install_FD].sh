#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

if [ "$FD_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

if [ "$FD_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via ${WSE__DISTRIB} package manager"
    pkg_install fd-find
    if ! command -v fd && command -v fdfind; then
        sudo mkdir -p /usr/local/bin
        sudo ln -s "$(command -v fdfind 2> /dev/null)" /usr/local/bin/fd
    fi
else
    Plan::log.mod "Build/install via cargo"
    cd "$FD_DL_PATH"
    cargo install --path .

    Plan::log.mod 'Cleaning up'
    cd .. && rm -rf "$FD_DL_PATH"
fi

Plan::log.mod ' '
