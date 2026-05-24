#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

RUST_PURGE='false'
RUST_USE_PKGMAN='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --rust-purge)
            RUST_PURGE='true'
            ;;
        --rust-use-pkgman)
            RUST_USE_PKGMAN='true'
            ;;
        --rust-rustup-args)
            RUST_RUSTUP_ARGS="$2"
            shift
            ;;
    esac
    shift
done

#
# Environment
#

Plan::vcache.add local RUST_USE_PKGMAN "$RUST_USE_PKGMAN"
Plan::vcache.add local RUST_RUSTUP_ARGS "$RUST_RUSTUP_ARGS"

if command -v cargo; then
    if [ "$RUST_PURGE" != 'true' ]; then
        Plan::log.mod 'Skipping'
        Plan::vcache.add local RUST_SKIP_INSTALL true
        exit 0
    fi
fi

Plan::log.mod 'Purging Cargo/Rust'

pkg_remove cargo rustup
rm -rf "${HOME}/.cargo"

IFS=' ' read -ra shells <<< "$WSE__SHELLS"
for sh in "${shells[@]}"; do
    if [ "$sh" = 'bash' ] || [ "$sh" = 'zsh' ]; then
        sed -i '/$HOME/\.cargo\/env/d' "${HOME}/.${sh}rc" || true
    fi
done

Plan::log.mod ' '
