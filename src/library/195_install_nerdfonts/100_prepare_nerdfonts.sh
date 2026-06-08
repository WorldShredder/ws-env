#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090,SC1091

set -eo pipefail
trap 'exit $?' ERR

NF_TAG=''
NF_LIST='false'
DEFAULT_FONT='ubuntumono' # >= 0.8.0
skip_install='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --nerdfonts-tag)
            NF_TAG="$2"
            shift
            ;;
        --nerdfonts-fonts)
            NF_FONTS="$2"
            [ -z "${NF_FONTS// /}" ] \
                && skip_install='true'
            shift
            ;;
        --nerdfonts-otf)
            NF_OTF='true'
            ;;
        --nerdfonts-list)
            NF_LIST='true'
            ;;
        --nerdfonts-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${pwd}/scripts/helpers.sh"

#
# List Fonts
#

if [ "$NF_LIST" = 'true' ]; then
    Plan::log.mod "Fetching '${NF_TAG:-latest}' font list"
    font_list="$(nf_list_fonts)"

    Plan::log.mod 'Nav: [j] Down [k] Up [q]uit'
    exec 5> /dev/tty
    less >&5 <<< "$font_list" || {
        Plan::log.mod -c 1 'Failed to fetch font list'
        exec 5>&-
        exit 1
    }
    exec 5>&-
    Plan::log.mod ' '
    Plan::abort
fi

#
# Environment
#

if [ "$skip_install" ]; then
    Plan::vcache.add local NF_SKIP_INSTALL true
    Plan::log.mod 'Skipping'
    exit 0
elif [ -z "$NF_FONTS" ]; then
    NF_FONTS="$DEFAULT_FONT"
fi

Plan::vcache.add local NF_TAG "$NF_TAG"
Plan::vcache.add local NF_FONTS "$NF_FONTS"
Plan::vcache.add local NF_OTF "$NF_OTF"

Plan::log.mod ' '
