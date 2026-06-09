#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

if [ "$RIPGREP_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

declare -a cargo_args
[ -n "$RIPGREP_CARGO_ARGS" ] \
    && IFS=' ' read -ra cargo_args <<< "$RIPGREP_CARGO_ARGS"

if [ "$RIPGREP_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via ${WSE__DISTRIB} package manager"
    pkg_install ripgrep
elif [ -n "$RIPGREP_VERSION" ]; then
    Plan::log.mod "Installing version '$RIPGREP_VERSION' via cargo-binstall"
    if [ "$RIPGREP_VERSION" = 'latest' ]; then
        cargo binstall "${cargo_args[@]}" -y 'ripgrep'
    else
        cargo binstall "${cargo_args[@]}" -y "ripgrep@${RIPGREP_VERSION}"
    fi
else
    Plan::log.mod "Build/install via cargo"
    cd "$RIPGREP_DL_PATH"
    cargo install "${cargo_args[@]}" --path .

    Plan::log.mod 'Cleaning up'
    cd .. && rm -rf "$RIPGREP_DL_PATH"
fi

Plan::log.mod ' '
