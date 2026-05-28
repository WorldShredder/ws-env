#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

SESH_TAG=''
SESH_COMMIT=''
SESH_USE_PKGMAN='false'
SESH_EXTRAS='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --sesh-tag)
            SESH_TAG="$2"
            shift
            ;;
        --sesh-commit)
            SESH_COMMIT="$2"
            shift
            ;;
        --sesh-purge | --purge)
            SESH_PURGE='true'
            ;;
        --sesh-extras | --extras)
            SESH_EXTRAS='true'
            ;;
        --sesh-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if [ -n "$SESH_COMMIT" ] && ! [[ "$SESH_COMMIT" =~ ^[a-f0-9]+$ ]]; then
    Plan::log.mod -c 1 "Invalid commit ID '$SESH_COMMIT'"
    exit 1
fi

if [ -z "$SESH_COMMIT" ] && [ -z "$SESH_TAG" ]; then
    if ! command -v go; then
        Plan::log.mod -c 1 "Require 'go' (command not found)"
        exit 1
    fi
    SESH_USE_PKGMAN='true'
fi

#
# Environment
#

Plan::vcache.add local SESH_TAG "$SESH_TAG"
Plan::vcache.add local SESH_COMMIT "$SESH_COMMIT"
Plan::vcache.add local SESH_USE_PKGMAN "$SESH_USE_PKGMAN"
Plan::vcache.add local SESH_EXTRAS "$SESH_EXTRAS"

#
# Remove Install
#

if [ "$SESH_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging Sesh'

    sudo rm -rf \
        "${GOPATH}/bin/sesh" \
        "$(command -v sesh 2> /dev/null || true)"

    if command -v sesh; then
        Plan::log.mod -c 1 'Failed to purge Sesh'
        exit 1
    fi
fi

if command -v sesh; then
    Plan::log.mod 'Skipping'
    Plan::vcache.add local SESH_SKIP_INSTALL true
    exit 0
fi

Plan::log.mod ' '
