#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

FD_TAG=''
FD_COMMIT=''
FD_USE_PKGMAN='false'
FD_EXTRAS='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --fd-tag)
            FD_TAG="$2"
            shift
            ;;
        --fd-commit)
            FD_COMMIT="$2"
            shift
            ;;
        --fd-purge | --purge)
            FD_PURGE='true'
            ;;
        --fd-use-pkgman | --pkgman)
            FD_USE_PKGMAN='true'
            ;;
        --fd-extras | --extras)
            FD_EXTRAS='true'
            ;;
        --fd-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if [ -n "$FD_COMMIT" ] && ! [[ "$FD_COMMIT" =~ ^[a-f0-9]+$ ]]; then
    Plan::log.mod -c 1 "Invalid commit ID '$FD_COMMIT'"
    exit 1
fi

if [ "$FD_USE_PKGMAN" != 'true' ] && ! command -v cargo; then
    Plan::log.mod -c 1 "Require 'cargo' (command not found)"
    exit 1
fi

#
# Environment
#

Plan::vcache.add local FD_TAG "$FD_TAG"
Plan::vcache.add local FD_COMMIT "$FD_COMMIT"
Plan::vcache.add local FD_USE_PKGMAN "$FD_USE_PKGMAN"
Plan::vcache.add local FD_EXTRAS "$FD_EXTRAS"

#
# Remove Install
#

case "$WSE__DISTRIB" in
    debian) bin_name='fdfind' ;;
    fedora) bin_name='fd' ;;
esac

if [ "$FD_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging FD'

    pkg_remove fd-find || true
    cargo uninstall fd-find || true

    sudo rm -rf \
        "/usr/bin/${bin_name}" \
        "/usr/local/bin/${bin_name}" \
        '/usr/local/bin/fd' \
        "${HOME}/.local/share/${bin_name}" \
        "${HOME}/.local/bin/${bin_name}" \
        "${HOME}/.cargo/bin/fd" \
        "$(command -v "${bin_name}" 2> /dev/null || true)"

    if command -v "$bin_name"; then
        Plan::log.mod -c 1 'Failed to purge FD'
        exit 1
    fi
fi

if command -v "$bin_name"; then
    Plan::log.mod 'Skipping'
    Plan::vcache.add local FD_SKIP_INSTALL true
    exit 0
fi

Plan::log.mod ' '
