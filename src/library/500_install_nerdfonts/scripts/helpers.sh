#!/usr/bin/env bash

NF_API_URL="${WSE__GITHUB_API}/ryanoasis/nerd-fonts/releases/latest"
[ -n "$NF_TAG" ] \
    && NF_API_URL="${WSE__GITHUB_API}/ryanoasis/nerd-fonts/releases/tags/${NF_TAG}"

nf_get_fonts() {
    local query='.assets | .[] | {name: .name, location: .browser_download_url}'
    jq "$query" <(curl -fsL "$NF_API_URL") 2> /dev/null
}

nf_list_fonts() {
    local font_data
    font_data="$(nf_get_fonts)"
    local query='.name | select(. | test("\\.tar\\.xz$")) | sub("\\.tar\\.xz$";"")'
    local font_list
    font_list="$(jq -r "$query" <<< "$font_data")"
    [ -n "${font_list// /}" ] \
        && printf '%s' "$font_list"
}

nf_get_location() {
    local font_data
    font_name="${1,,}"
    font_data="${2:-$(nf_get_fonts)}"

    local query="select(.name | ascii_downcase | \
        test(\"^${font_name}\\\.tar\\\.xz\$\")) | .location"

    jq -r "$query" <<< "$font_data" 2> /dev/null \
        | grep -oE '^https://github\.com/ryanoasis/nerd-fonts/.+'
}

nf_extract_font() {
    local src="$1"
    local dest="$2"
    local order="${3:-ttf otf}"

    for ftype in $order; do
        tar -xJf "$src" -C "$dest" --wildcards "*.$ftype" || continue
        printf '%s' "$ftype"
        return
    done
    return 1
}

nf_install_font() {
    local font_name="$1"
    local font_data="$2"
    if [ -z "$font_data" ]; then
        Plan::log.mod 'Fetching Nerdfonts metadata'
        font_data="$(nf_get_fonts)"
    fi

    Plan::log.mod "Fetching location of font '$font_name'"
    local location
    location="$(nf_get_location "$font_name" "$font_data")" || {
        Plan::log.mod -c 1 \
            "Font '$font_name' doesn't exist or Github API rate limit reached"
        exit 1
    }

    local nf_cache="${PLAN__PATH_CACHE}/nf-cache"
    mkdir -p "$nf_cache"

    local system_fonts='/usr/share/fonts'
    local font_archive="${nf_cache}/${font_name}.tar.xz"
    local nf_data="${nf_cache}/font_data/${font_name}"
    mkdir -p "$nf_data"

    local preference='ttf otf'
    [ "$NF_OTF" = 'true' ] \
        && preference='otf ttf'

    Plan::log.mod "Downloading font '$font_name'"
    curl -fL "$location" -o "$font_archive"

    Plan::log.mod "Extracting font '$font_name'"
    local font_type
    font_type="$(nf_extract_font "$font_archive" "$nf_data" "$preference")"

    Plan::log.mod "Installing font '$font_name' (${font_type})"
    local install_path="${system_fonts}/truetype"
    [ "$font_type" = 'otf' ] \
        && install_path="${system_fonts}/opentype"
    sudo cp -ru "$nf_data" "$install_path"

    Plan::log.mod "Cleaning cache"
    rm -r "$nf_data" "$font_archive"
}

nf_install_fonts() {
    local fonts="$1"
    local font_data="$2"
    if [ -z "$font_data" ]; then
        Plan::log.mod 'Fetching Nerdfont metadata'
        font_data="$(nf_get_fonts)"
    fi
    local font
    IFS=, read -ra fonts <<< "$fonts"
    for font in "${fonts[@]}"; do
        nf_install_font "$font" "$font_data"
    done
}
