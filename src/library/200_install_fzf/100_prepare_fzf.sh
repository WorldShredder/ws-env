#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

FZF_TAG=''
FZF_COMMIT=''
FZF_USE_PKGMAN='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --fzf-tag)
            FZF_TAG="$2"
            shift
            ;;
        --fzf-commit)
            FZF_COMMIT="$2"
            shift
            ;;
        --fzf-purge | --purge)
            FZF_PURGE='true'
            ;;
        --fzf-use-pkgman | --pkgman)
            FZF_USE_PKGMAN='true'
            ;;
        --fzf-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if [ -n "$FZF_COMMIT" ] && ! [[ "$FZF_COMMIT" =~ ^[a-f0-9]+$ ]]; then
    Plan::log.mod -c 1 "Invalid commit ID '$FZF_COMMIT'"
    exit 1
fi

#
# Remove Install
#

if [ "$FZF_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging FZF'
    pkg_remove fzf || true

    rm -rf \
        /usr/bin/fzf \
        /usr/local/bin/fzf \
        /usr/local/opt/fzf \
        "${HOME}/.local/fzf" \
        "${HOME}/.local/opt/fzf" \
        "$(command -v fzf 2> /dev/null || true)"

    if command -v fzf; then
        Plan::log.mod -c 1 'Failed to purge FZF'
        exit 1
    fi
fi

if command -v fzf; then
    Plan::log.mod 'Skipping'
    Plan::vcache.add local FZF_SKIP_INSTALL true
    exit 0
fi

#
# Environment
#

Plan::vcache.add local FZF_TAG "$FZF_TAG"
Plan::vcache.add local FZF_COMMIT "$FZF_COMMIT"
Plan::vcache.add local FZF_USE_PKGMAN "$FZF_USE_PKGMAN"

Plan::log.mod ' '
