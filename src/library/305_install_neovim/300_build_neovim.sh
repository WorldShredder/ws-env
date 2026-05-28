#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$NEOVIM_SKIP_INSTALL" = 'true' ] || [ "$NEOVIM_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

cd "$NEOVIM_DL_PATH"

#
# Install Dependencies
#

Plan::log.mod 'Installing build dependencies'

declare -a required=(ninja-build gettext cmake)
case "$WSE__DISTRIB" in
    debian) required+=(build-essential) ;;
    fedora) required+=(gcc make glibc-gconv-extra) ;;
esac

pkg_install "${required[@]}"

#
# Build Binary
#

Plan::log.mod 'Building binaries'
make CMAKE_BUILD_TYPE=Release

Plan::log.mod ' '
