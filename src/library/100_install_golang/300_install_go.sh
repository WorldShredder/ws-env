#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$GOLANG_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

Plan::log.mod "Installing Go v${GOLANG_VERSION}"
sudo -u "$GOLANG_OWNER" tar \
    -xzf "${PLAN__PATH_CACHE}/golang.tar.gz" -C "$GOLANG_INSTALL_DIR"

# Since we don't source any runtime configs we must ensure GOPATH and PATH
# are included in environments which use go binary

Plan::vcache.add -e global GOPATH "${GOLANG_GOPATH}"
Plan::vcache.add -e global PATH \
    "${GOLANG_INSTALL_DIR}/go/bin:${GOPATH}/bin:${PATH}"

if [ -z "$WSE__SHELLS" ]; then
    Plan::log.mod ' '
    exit 0
fi

Plan::log.mod "Configuring shells: $WSE__SHELLS"
IFS=' ' read -ra shells <<< "$WSE__SHELLS"
for sh in "${shells[@]}"; do
    path="${HOME}/.shellrc.d/${sh}/100_golang_path.sh"
    printf 'export GOPATH="%s"\n' "$GOPATH" > "$path"
    printf 'export PATH="%s:%s:$PATH"\n' \
        "${GOLANG_INSTALL_DIR}/go/bin" \
        "${GOPATH}/bin" \
        >> "$path"
done

Plan::log.mod ' '
