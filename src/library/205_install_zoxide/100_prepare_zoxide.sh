#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

ZOXIDE_TAG=''
ZOXIDE_COMMIT=''
ZOXIDE_USE_PKGMAN='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --zoxide-tag)
            ZOXIDE_TAG="$2"
            shift
            ;;
        --zoxide-commit)
            ZOXIDE_COMMIT="$2"
            shift
            ;;
        --zoxide-purge | --purge)
            ZOXIDE_PURGE='true'
            ;;
        --zoxide-use-pkgman | --pkgman)
            ZOXIDE_USE_PKGMAN='true'
            ;;
        --zoxide-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if [ -n "$ZOXIDE_COMMIT" ] && ! [[ "$ZOXIDE_COMMIT" =~ ^[a-f0-9]+$ ]]; then
    Plan::log.mod -c 1 "Invalid commit ID '$ZOXIDE_COMMIT'"
    exit 1
fi

#
# Remove Install
#

if [ "$ZOXIDE_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging Zoxide'
    pkg_remove zoxide || true

    sudo rm -rf \
        "$(command -v zoxide 2> /dev/null || true)"

    if command -v zoxide; then
        Plan::log.mod -c 1 'Failed to purge Zoxide'
        exit 1
    fi
fi

if command -v zoxide; then
    Plan::log.mod 'Skipping'
    Plan::vcache.add local ZOXIDE_SKIP_INSTALL true
    exit 0
fi

#
# Environment
#

Plan::vcache.add local ZOXIDE_TAG "$ZOXIDE_TAG"
Plan::vcache.add local ZOXIDE_COMMIT "$ZOXIDE_COMMIT"
Plan::vcache.add local ZOXIDE_USE_PKGMAN "$ZOXIDE_USE_PKGMAN"

Plan::log.mod ' '
