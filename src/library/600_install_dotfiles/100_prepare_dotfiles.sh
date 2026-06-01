#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

DOTFILES_TAG=''
DOTFILES_COMMIT=''
DOTFILES_LIBRARY=''

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
        --dotfiles-lib)
            if [ -z "${2// /}" ]; then
                Plan::log.mod -c 1 '--dotfiles-lib value cannot be empty'
                exit 1
            fi
            DOTFILES_LIBRARY="$2"
            shift
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
# Scan Repo Library
#

# check dotfiles lib/ dir before continuing
if [ -n "$DOTFILES_LIBRARY" ]; then
    Plan::log.mod "Scanning repo for: $DOTFILES_LIBRARY"
    IFS=, read -ra library_targets <<< "$DOTFILES_LIBRARY"

    api_url="${WSE__GITHUB_API}/worldshredder/dotfiles/contents/lib"
    [ -n "${DOTFILES_TAG:-"${DOTFILES_COMMIT}"}" ] \
        && api_url+="/?ref=${DOTFILES_TAG:-"${DOTFILES_COMMIT}"}"

    query='.[] | select(.type == "dir") | .name'
    api_out="$(curl -fsL "$api_url" | jq -r "$query")" || {
        Plan::log.mod -c 1 'Failed to scan repo'
        exit 1
    }
    read -d '\n' -ra library <<< "${api_out}\\n"

    for lib in "${library_targets[@]}"; do
        if [[ " ${library[*]} " != *" $lib "* ]]; then
            Plan::log.mod -c 1 "Lib '$lib' not in: ${library[*]}"
            exit 1
        fi
    done
fi

#
# Environment
#

Plan::vcache.add local DOTFILES_TAG "$DOTFILES_TAG"
Plan::vcache.add local DOTFILES_COMMIT "$DOTFILES_COMMIT"
Plan::vcache.add local DOTFILES_LIBRARY "$DOTFILES_LIBRARY"

Plan::log.mod ''
