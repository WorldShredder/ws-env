#!/usr/bin/env bash

while :; do
    case "$1" in
        --golang-update)
            GOLANG_UPDATE='true'
            ;;
        --golang-purge)
            GOLANG_PURGE='true'
            ;;
        --golang-version)
            GOLANG_VERSION="$2"
            shift
            ;;
        --golang-install-dir)
            GOLANG_INSTALL_DIR="$2"
            shift
            ;;
        --golang-gopath)
            GOLANG_GOPATH="$2"
            shift
            ;;
        --)
            shift
            break
            ;;
        *) break ;;
    esac
    shift
done
