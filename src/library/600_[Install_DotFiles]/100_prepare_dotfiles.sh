#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

DOTFILES_TAG=''
DOTFILES_COMMIT=''

while [ $# -gt 0 ]; do
    case "$1" in
        --dotfiles-tag)
            DOTFILES_TAG="$2"
            shift
            ;;
        --dotfiles-commit)
            DOTFILES_COMMIT="$2"
            shift
            ;;
        --dotfiles-purge | --purge)
            DOTFILES_PURGE='true'
            ;;
        --dotfiles-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if [ -n "$DOTFILES_COMMIT" ] && ! [[ "$DOTFILES_COMMIT" =~ ^[a-f0-9]+$ ]]; then
    Plan::log.mod -c 1 "Invalid commit ID '$DOTFILES_COMMIT'"
    exit 1
fi

#
# Remove Install
#

if [ "$DOTFILES_PURGE" = 'true' ]; then
    Plan::log.mod 'Purging DotFiles'
fi
