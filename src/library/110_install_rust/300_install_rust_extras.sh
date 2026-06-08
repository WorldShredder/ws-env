#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$RUST_EXTRAS" != 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

if command -v cargo-binstall; then
    Plan::log.mod 'Upgrading cargo-binstall'
    cargo binstall cargo-binstall
else
    Plan::log.mod 'Installing cargo-binstall'
    cargo install cargo-binstall --locked
fi

Plan::log.mod ' '
