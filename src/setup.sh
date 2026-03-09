#!/usr/bin/env bash

set -eo pipefail

save_state() {
    trap - ERR INT TERM HUP QUIT
    echo "NEXT_STEP=$NEXT_STEP; NEXT_SUB_STEP=$NEXT_SUB_STEP" \
        > ~/.ws-env-state.conf
}

trap 'log.error "An error occurred"; save_state; exit 1' ERR
trap 'log.warn "Exiting early"; save_state; exit 0' INT TERM HUP QUIT

if [ -f ~/.ws-env-state.conf ] ; then
    source ~/.ws-env-state.conf
else
    NEXT_STEP=1
    NEXT_SUB_STEP=1
fi

R='\e[31m'; G='\e[32m'; Y='\e[33m'
B='\e[34m'; M='\e[35m'; C='\e[36m'
X='\e[0m'; #E='\e[1m'

alias '@inl'='_LOG_INLINE=1'
alias '@nop'='_LOG_NOPRE=1'

log.init() {
    local color="$1"; shift
    local prefix="$1"; shift
    [ -n "$_LOG_NOPRE" ] && prefix=''
    local message="${color}${prefix}${*}${X}"
    local opts='-e'
    [ -n "$_LOG_INLINE" ] && opts+='n'
    echo -e "$opts" "$message"
}
log.echo()  { log.init '' '' "${*}"; }
log.info()  { log.init "${B}" '❖ ' "${*}${X}"; }
log.info2() { log.init "${C}" '❖ ' "${*}${X}"; }
log.ok()    { log.init "${G}" '✔ ' "${*}${X}"; }
log.warn()  { log.init "${Y}" '✖ ' "${*}${X}"; }
log.error() { log.init "${R}" '✖ ' "${*}${X}"; }

# TODO: Implement 'sudo -u __USER__' scheme to handle sudo call
if [ "$(id -u)" = '0' ] ; then
    log.error 'Do not run with root privileges'
    exit 1
fi



log.info 'Step 1: Installing Required Packages'

if [ "$NEXT_STEP" = '1' ] ; then
    required_pkgs='curl git vim-gtk3'
    log.info2 "Step 1.1: Updating apt and installing: $required_pkgs"
    sudo apt update
    sudo apt install -y $required_pkgs
    NEXT_STEP=2
fi



log.info 'Step 2: Installing Tmux'

if [ "$NEXT_STEP" = '2' ] ; then
    if [ "$NEXT_SUB_STEP" = '1' ] ; then
        log.info2 'Step 2.1: Downloading Tmux installer'
        git clone https://github.com/worldshredder/tmux-installer.git
        NEXT_SUB_STEP=2
    fi

    if [ "$NEXT_SUB_STEP" = '2' ] ; then
        log.info2 'Step 2.2: Running Tmux installer'
        sudo tmux-installer/src/install.sh -r latest -f jetbrainsmono \
            -c https://gist.github.com/be7cd4d6dcf9ca1057e3e0310b73603e.git
    fi

    NEXT_SUB_STEP=1
    NEXT_STEP=3
fi



log.info 'Step 3: Installing FZF'

if [ "$NEXT_STEP" = '3' ] ; then
    if [ "$NEXT_SUB_STEP" = '1' ] ; then
        log.info2 'Step 3.1: Creating directories'
        mkdir -p ~/.local/opt
        NEXT_SUB_STEP=2
    fi

    if [ "$NEXT_SUB_STEP" = '2' ] ; then
        log.info2 'Step 3.2: Downloading FZF'
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.local/opt/fzf
        NEXT_SUB_STEP=3
    fi

    if [ "$NEXT_SUB_STEP" = '3' ] ; then
        log.info2 'Step 3.3: Running FZF installer'
        ~/.local/opt/fzf/install --all
    fi

    NEXT_SUB_STEP=1
    NEXT_STEP=4
fi



log.info 'Step 4: Installing Zoxide'

if [ "$NEXT_STEP" = '4' ] ; then
    if [ "$NEXT_SUB_STEP" = '1' ] ; then
        log.info2 'Step 4.1: Downloading and running installer'
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        NEXT_SUB_STEP=2
    fi

    if [ "$NEXT_SUB_STEP" = '2' ] ; then
        log.info2 'Step 4.2: Adding Zoxide to shell runtime config'
        echo 'PATH="${HOME}/.local/bin:$PATH"' >> ~/".${SHELL##*/}rc"
        echo "eval \"\$(zoxide init ${SHELL##*/})\"" >> ~/".${SHELL##*/}rc"
    fi

    NEXT_SUB_STEP=1
    NEXT_STEP=5
fi



log.info 'Step 5: Installing EZA'

if [ "$NEXT_STEP" = '5' ] ; then
    if [ "$NEXT_SUB_STEP" = '1' ] ; then
        log.info2 'Step 5.1: Downloading and running installer'
        curl -sSL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | sudo tar -xz -C /usr/local/bin
        NEXT_SUB_STEP=2
    fi

    if [ "$NEXT_SUB_STEP" = '2' ] ; then
        log.info2 "Step 5.2: Adding 'ezg' alias to shell runtime config"
        echo 'alias ezg="eza -lhT --git --git-ignore"' >> ~/".${SHELL##*/}rc"
    fi

    NEXT_SUB_STEP=1
    NEXT_STEP=6
fi



log.info 'Step 6: Installing FD'

if [ "$NEXT_STEP" = '6' ] ; then
    if [ "$NEXT_SUB_STEP" = '1' ] ; then
        log.info2 'Step 6.1: Downloading and installing deb package'
        sudo dpkg -i "$(curl -w "%{filename_effective}" -LO "$(jq -r '.assets[] | select(.name | test("^fd_.*_amd64\\.deb$")) | .browser_download_url' <(curl -fsL https://api.github.com/repos/sharkdp/fd/releases/latest))")"
        NEXT_SUB_STEP=2
    fi

    if [ "$NEXT_SUB_STEP" = '2' ] ; then
        log.info2 'Step 6.2: Cleaning up'
        rm fd_*amd64.deb
    fi

    NEXT_SUB_STEP=1
    NEXT_STEP=7
fi



log.info 'Step 7: Installing Golang'

if [ "$NEXT_STEP" = '7' ] ; then
    log.info2 'Step 7.1: Downloading and running install script'
    curl -sL https://gist.github.com/WorldShredder/726c1add8067556a17a431fdd60517f0/raw | sudo GO_INSTALL_DIR="$HOME/.local/opt" bash
    NEXT_STEP=8
fi



log.info 'Step 8: Installing Sesh'

# Plugin: Sesh
if [ "$NEXT_STEP" = '8' ] ; then
    if [ "$NEXT_SUB_STEP" = '1' ] ; then
        log.info2 'Step 8.1: Installing Sesh via go'
        export GOPATH="$HOME/.local/go"
        export PATH="$HOME/.local/opt/go/bin:$HOME/.local/go/bin:$PATH"
        go install github.com/joshmedeski/sesh/v2@latest
        NEXT_SUB_STEP=2
    fi

    # Configure Sesh
    if [ "$NEXT_SUB_STEP" = '2' ] ; then
        log.info2 'Step 8.2: Setting up bindings and command completion'
        if [ "${SHELL##*/}" = 'zsh' ] ; then
            # Bindings
            curl -fsL https://gist.github.com/WorldShredder/65247a401947706b16d6e90eea11eff7/raw >> ~/.zshrc
            # Command Completion
            sesh completion zsh > _sesh
            mkdir -p ~/.zsh/completions
            cp _sesh ~/.zsh/completions/
            echo 'fpath=(~/.zsh/completions $fpath)' >> ~/.zshrc
            echo 'autoload -U compinit && compinit' >> ~/.zshrc
        elif [ "${SHELL##*/}" = 'bash' ] ; then
            # Bindings
            curl -fsL https://gist.github.com/WorldShredder/194033baaa80674743f82e09d3eb06a2/raw >> ~/.bashrc
            # Command Completion
            sesh completion bash > sesh-completion.bash
            mkdir -p ~/.local/share/bash-completion/completions
            cp sesh-completion.bash ~/.local/share/bash-completion/completions/sesh
        else
            true
        fi
    fi

    NEXT_SUB_STEP=1
    NEXT_STEP=9
fi



log.info 'Step 9: Installing Tmux Plugins'

if [ "$NEXT_STEP" = '9' ] ; then
    log.info2 "Step 9.1: Running 'tpm/bin/install_plugins'"
    ~/.tmux/plugins/tpm/bin/install_plugins || true
    NEXT_STEP=10
fi



log.info 'Step 10: Installing Vim Config & Plugins'

if [ "$NEXT_STEP" = '10' ] ; then
    if [ "$NEXT_SUB_STEP" = '1' ] ; then
        log.info2 'Step 10.1: Downloading and installing: Vim-Plug'
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        NEXT_SUB_STEP=2
    fi

    if [ "$NEXT_SUB_STEP" = '2' ] ; then
        log.info2 "Step 10.2: Downloading WorldShredder's Vim config"
        curl -sL https://gist.github.com/WorldShredder/4a304b97a162777f753dd097b5660565/raw > ~/.vimrc
        NEXT_SUB_STEP=3
    fi

    if [ "$NEXT_SUB_STEP" = '3' ] ; then
        log.info2 'Step 10.3: Installing Vim plugins'
        vim -c ':PlugInstall'
    fi
fi

rm -f ~/.ws-env-state.conf

log.ok 'Installation complete! Restart shell to complete setup ;)'

exit 0
