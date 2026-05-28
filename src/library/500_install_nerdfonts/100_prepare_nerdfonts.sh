#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090,SC1091

set -eo pipefail
trap 'exit $?' ERR

NF_TAG=''
NF_COMMIT=''
NF_LIST='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --nf-tag)
            NF_TAG="$2"
            shift
            ;;
        --nf-commit)
            NF_COMMIT="$2"
            shift
            ;;
        --nf-fonts)
            NF_FONTS="$2"
            shift
            ;;
        --nf-otf)
            NF_OTF='true'
            ;;
        --nf-list)
            NF_LIST='true'
            ;;
        --nf-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

if [ -n "$NF_COMMIT" ] && ! [[ "$NF_COMMIT" =~ ^[a-f0-9]+$ ]]; then
    Plan::log.mod -c 1 "Invalid commit ID '$NF_COMMIT'"
    exit 1
fi

pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${pwd}/scripts/helpers.sh"

#
# List Fonts
#

if [ "$NF_LIST" = 'true' ]; then
    Plan::log.mod 'Fetching font list'
    font_list="$(nf_list_fonts)"

    Plan::log.mod 'Viewing font list'
    exec 5> /dev/tty
    less >&5 <<< "$font_list" || {
        Plan::log.mod -c 1 'Failed to fetch font list'
        exec 5>&-
        exit 1
    }
    exec 5>&-
    Plan::abort
fi

#
# Environment
#

if [ -z "$NF_FONTS" ]; then
    Plan::vcache.add local NF_SKIP_INSTALL true
    Plan::log.mod 'Skipping'
    exit 0
fi

Plan::vcache.add local NF_TAG "$NF_TAG"
Plan::vcache.add local NF_COMMIT "$NF_COMMIT"
Plan::vcache.add local NF_FONTS "$NF_FONTS"
Plan::vcache.add local NF_OTF "$NF_OTF"

Plan::log.mod ' '
