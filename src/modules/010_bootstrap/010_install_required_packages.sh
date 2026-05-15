#!/usr/bin/env bash

declare -a required
case "$__DISTRIB__" in
    debian) required+=(curl git tar xz-utils unzip jq) ;;
    fedora) required+=(curl git tar xz-utils unzip jq) ;;
    *) exit 1 ;;
esac

pkg_update
pkg_install "${required[@]}"
