#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$RUST_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

if [ "$RUST_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via ${WSE__DISTRIB} package manager"
    pkg_install cargo
    Plan::log.mod ' '
    exit 0
fi

Plan::log.mod 'Downloading Rustup script'
curl --proto '=https' --tlsv1.2 -f https://sh.rustup.rs \
    > "${PLAN__PATH_CACHE}/rustup"

Plan::log.mod 'Installing Rust via Rustup'
IFS=' ' read -ra args <<< "$RUST_RUSTUP_ARGS"
sh "${PLAN__PATH_CACHE}/rustup" -y --no-modify-path "${args[@]}"

Plan::log.mod 'Verifying install'
source "${HOME}/.cargo/env"
cargo --version

Plan::log.mod "Configuring shells: $WSE__SHELLS"
IFS=' ' read -ra shells <<< "$WSE__SHELLS"
for sh in "${shells[@]}"; do
    # Compatible with: sh/bash/zsh/ash/dash/pdksh
    name='110_rust_env.sh'
    printf 'source "%s/.cargo/env"\n' "$HOME" \
        > "${WSE__SHELLRCD}/${name}"
done

Plan::log.mod ' '
