#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

RIPGREP_TAG=''
RIPGREP_COMMIT=''
RIPGREP_VERSION=''
RIPGREP_USE_PKGMAN='false'
RIPGREP_CARGO_ARGS=''

while [ $# -gt 0 ]; do
    case "$1" in
        --ripgrep-tag)
            RIPGREP_TAG="$2"
            shift
            ;;
        --ripgrep-commit)
            RIPGREP_COMMIT="$2"
            shift
            ;;
        --ripgrep-version | --binstall)
            if ! command -v cargo-binstall; then
                Plan::log.mod -c 1 "--ripgrep-version requires package 'cargo-binstall'"
                exit 1
            fi
            RIPGREP_VERSION='latest'
            if [ "$1" != '--binstall' ]; then
                RIPGREP_VERSION="$2"
                shift
            fi
            ;;
        --ripgrep-purge | --purge)
            RIPGREP_PURGE='true'
            ;;
        --ripgrep-pkgman | --pkgman)
            RIPGREP_USE_PKGMAN='true'
            ;;
        --ripgrep-cargo-args | --cargo-args)
            RIPGREP_CARGO_ARGS="$2"
            shift
            ;;
        --ripgrep-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if [ -n "$RIPGREP_COMMIT" ] && ! [[ "$RIPGREP_COMMIT" =~ ^[a-f0-9]+$ ]]; then
    Plan::log.mod -c 1 "Invalid commit ID '$RIPGREP_COMMIT'"
    exit 1
fi

if [ -n "$RIPGREP_VERSION" ] && ! [[ "$RIPGREP_VERSION" =~ ^(latest|([0-9]\.?)+)$ ]]; then
    Plan::log.mod -c 1 "Invalid version number '$RIPGREP_VERSION'"
    exit 1
fi

if [ "$RIPGREP_USE_PKGMAN" != 'true' ] && ! command -v cargo; then
    Plan::log.mod -c 1 "Require 'cargo' (command not found)"
    exit 1
fi

#
# Environment
#

Plan::vcache.add local RIPGREP_TAG "$RIPGREP_TAG"
Plan::vcache.add local RIPGREP_COMMIT "$RIPGREP_COMMIT"
Plan::vcache.add local RIPGREP_VERSION "$RIPGREP_VERSION"
Plan::vcache.add local RIPGREP_USE_PKGMAN "$RIPGREP_USE_PKGMAN"
Plan::vcache.add local RIPGREP_CARGO_ARGS "$RIPGREP_CARGO_ARGS"

#
# Remove Install
#

if [ "$RIPGREP_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging Ripgrep'

    pkg_remove ripgrep || true
    cargo uninstall ripgrep || true

    sudo rm -rf \
        /usr/bin/rg \
        /usr/local/bin/rg \
        "${HOME}/.local/bin/rg" \
        "$(command -v rg 2> /dev/null || true)"

    if command -v rg; then
        Plan::log.mod -c 1 'Failed to purge Ripgrep'
        exit 1
    fi
fi

if command -v rg; then
    Plan::log.mod 'Skipping'
    Plan::vcache.add local RIPGREP_SKIP_INSTALL true
    exit 0
fi

Plan::log.mod ' '
