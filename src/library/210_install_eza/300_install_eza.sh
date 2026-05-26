#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

if [ "$EZA_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

if [ "$EZA_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via ${WSE__DISTRIB} package manager"
    pkg_install eza
else
    Plan::log.mod "Build/install via cargo"
    cd "$EZA_DL_PATH"
    cargo install --path .

    Plan::log.mod 'Cleaning up'
    cd .. && rm -rf "$EZA_DL_PATH"
fi

Plan::log.mod ' '
