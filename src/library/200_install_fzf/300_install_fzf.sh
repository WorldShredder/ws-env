#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$FZF_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

if [ "$FZF_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via ${WSE__DISTRIB} package manager"
    pkg_install fzf
else
    Plan::log.mod "Copying FZF to /usr/local/opt"
    rm -rf "$FZF_DL_PATH/.git"
    sudo mkdir -p /usr/local/opt
    sudo cp -r "$FZF_DL_PATH" /usr/local/opt

    # We have to setup the binary first as root
    Plan::log.mod 'Installing binary'
    sudo /usr/local/opt/fzf/install --bin

    # Now we can setup runtime config and completions
    Plan::log.mod 'Setting up completions'
    /usr/local/opt/fzf/install --all

    Plan::log.mod 'Cleaning up'
    rm -rf "$FZF_DL_PATH"
fi

Plan::log.mod ' '
