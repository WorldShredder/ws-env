# WorldShredder Zsh Bindings for Tmux Sesh
# Original: https://github.com/joshmedeski/sesh#zsh-keybind

__sesh_search() {
    {
        local session
        case "$1" in
            session)
                session="$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '  ')"
                ;;
            all)
                tput smcup
                session="$(
                    sesh list --icons | fzf --reverse --margin 5% \
                    --no-sort --ansi --border-label ' sesh ' --prompt '  ' \
                    --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
                    --bind 'tab:down,btab:up' \
                    --bind 'ctrl-a:change-prompt(  )+reload(sesh list --icons)' \
                    --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t --icons)' \
                    --bind 'ctrl-g:change-prompt(  )+reload(sesh list -c --icons)' \
                    --bind 'ctrl-x:change-prompt(  )+reload(sesh list -z --icons)' \
                    --bind 'ctrl-f:change-prompt(  )+reload(fd -H -d 3 -t d -E .Trash . ~)' \
                    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(  )+reload(sesh list --icons)' \
                    --preview-window 'right:55%' \
                    --preview 'sesh preview {}'
                )"
                tput rmcup
                ;;
        esac
        zle reset-prompt &>/dev/null || true
        [ -z "$session" ] &&\
            return
        sesh connect "$session"
    }
}

sesh_search_sessions() {
    { exec </dev/tty; exec <&1; __sesh_search 'session'; }
}
sesh_search_all() {
    { exec </dev/tty; exec <&1; __sesh_search 'all'; }
}

zle     -N             sesh_search_sessions
bindkey -M emacs '\es' sesh_search_sessions
bindkey -M vicmd '\es' sesh_search_sessions
bindkey -M viins '\es' sesh_search_sessions
zle     -N             sesh_search_all
bindkey -M emacs '\ee' sesh_search_all
bindkey -M vicmd '\ee' sesh_search_all
bindkey -M viins '\ee' sesh_search_all
