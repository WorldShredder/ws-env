#!/usr/bin/env bash

declare -a required
case "$__DISTRIB__" in
    debian) required+=(curl git tar xz-utils unzip) ;;
    fedora) required+=(curl git tar xz-utils unzip) ;;
    *) exit 1 ;;
esac

pkg_update
pkg_install "${required[@]}"
