#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$TMUX_SKIP_INSTALL" = 'true' ] || [ "$TMUX_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

cd "$TMUX_DL_PATH"

#
# Install Dependencies
#

Plan::log.mod 'Installing build dependencies'

declare -a required=(gcc make bison autoconf automake pkg-config)
case "$WSE__DISTRIB" in
    debian) required+=(libevent-dev libncurses-dev) ;;
    fedora) required+=(libevent-devel ncurses-devel) ;;
esac

pkg_install "${required[@]}"

#
# Remove Install
#

if [ "$TMUX_PURGE" = 'true' ]; then
    Plan::log.mod 'Attempting to purge Tmux build'
    sudo make uninstall || true
fi

if command -v tmux; then
    if [ "$LUA_PURGE" = 'true' ]; then
        Plan::log.mod -c 1 'Failed to purge Tmux'
        exit 1
    fi
    Plan::log.mod 'Skipping'
    Plan::vcache.add local TMUX_SKIP_INSTALL true
    exit 0
fi

#
# Build Binary
#

Plan::log.mod 'Running autogen'
sh autogen.sh

Plan::log.mod 'Configuring build environment'
./configure

Plan::log.mod 'Building binaries'
make

Plan::log.mod ' '
