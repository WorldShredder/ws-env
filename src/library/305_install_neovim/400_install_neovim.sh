#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$NEOVIM_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

if [ "$NEOVIM_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via ${WSE__DISTRIB} package manager"
    pkg_install neovim
else
    Plan::log.mod 'Running make install'
    cd "$NEOVIM_DL_PATH"
    sudo make install

    Plan::log.mod 'Cleaning up'
    cd .. && rm -rf "${NEOVIM_DL_PATH}"
fi

Plan::log.mod ' '
