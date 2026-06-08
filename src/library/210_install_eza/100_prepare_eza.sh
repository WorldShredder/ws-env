#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

EZA_TAG=''
EZA_COMMIT=''
EZA_VERSION=''
EZA_USE_PKGMAN='false'
EZA_CARGO_ARGS=''
EZA_EXTRAS='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --eza-tag)
            EZA_TAG="$2"
            shift
            ;;
        --eza-commit)
            EZA_COMMIT="$2"
            shift
            ;;
        --eza-version | --binstall)
            if ! command -v cargo-binstall; then
                Plan::log.mod -c 1 "--eza-version requires package 'cargo-binstall'"
                exit 1
            fi
            EZA_VERSION='latest'
            if [ "$1" != '--binstall' ]; then
                EZA_VERSION="$2"
                shift
            fi
            ;;
        --eza-purge | --purge)
            EZA_PURGE='true'
            ;;
        --eza-pkgman | --pkgman)
            EZA_USE_PKGMAN='true'
            ;;
        --eza-cargo-args | --cargo-args)
            EZA_CARGO_ARGS="$2"
            shift
            ;;
        --eza-extras | --extras)
            EZA_EXTRAS='true'
            ;;
        --eza-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if [ -n "$EZA_COMMIT" ] && ! [[ "$EZA_COMMIT" =~ ^[a-f0-9]+$ ]]; then
    Plan::log.mod -c 1 "Invalid commit ID '$EZA_COMMIT'"
    exit 1
fi

if [ -n "$EZA_VERSION" ] && ! [[ "$EZA_VERSION" =~ ^(latest|([0-9]\.?)+)$ ]]; then
    Plan::log.mod -c 1 "Invalid version number '$EZA_VERSION'"
    exit 1
fi

if [ "$WSE__DISTRIB" = 'fedora' ] && [ "$EZA_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod -c 3 -d 2 'Warn: Eza not in repos (using fallback)'
    EZA_USE_PKGMAN='false'
fi

if [ "$EZA_USE_PKGMAN" != 'true' ] && ! command -v cargo; then
    Plan::log.mod -c 1 "Require 'cargo' (command not found)"
    exit 1
fi

#
# Environment
#

Plan::vcache.add local EZA_TAG "$EZA_TAG"
Plan::vcache.add local EZA_COMMIT "$EZA_COMMIT"
Plan::vcache.add local EZA_VERSION "$EZA_VERSION"
Plan::vcache.add local EZA_USE_PKGMAN "$EZA_USE_PKGMAN"
Plan::vcache.add local EZA_CARGO_ARGS "$EZA_CARGO_ARGS"
Plan::vcache.add local EZA_EXTRAS "$EZA_EXTRAS"

#
# Remove Install
#

if [ "$EZA_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging Eza'

    pkg_remove eza || true
    cargo uninstall eza || true

    sudo rm -rf \
        /usr/bin/eza \
        /usr/share/eza \
        /usr/local/bin/eza \
        /usr/local/share/eza \
        "${HOME}/.local/share/eza" \
        "${HOME}/.local/bin/eza" \
        "$(command -v eza 2> /dev/null || true)"

    if command -v eza; then
        Plan::log.mod -c 1 'Failed to purge Eza'
        exit 1
    fi
fi

if command -v eza; then
    Plan::log.mod 'Skipping'
    Plan::vcache.add local EZA_SKIP_INSTALL true
    exit 0
fi

Plan::log.mod ' '
