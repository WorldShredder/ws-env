> [!IMPORTANT]
> - This script is intended for **debian**-based systems.
> - Some features may be inaccessible outside of a [Qubes](https://qubes-os.org) environment.

<h1 align=center>PERSONAL ENVIRONMENT</h1>
<h3 align=center>Tmux + Vim</h3>
<br>

Installer for my personal developer environment. The installer will pickup where it left off if failures occur, although this feature is only partially implemented.

## Usage

```bash
git clone --depth 1 https://github.com/worldshredder/ws-env.git && ws-env/src/setup.sh
```

## Tools & Packages

- Vim GTK3 w/Vim-Plug
    - [Vim Config](https://gist.github.com/WorldShredder/4a304b97a162777f753dd097b5660565)
    - [Vim Bindings](https://gist.github.com/WorldShredder/4a304b97a162777f753dd097b5660565?permalink_comment_id=5950364#gistcomment-5950364)
- Tmux w/Sesh
    - [Tmux Config](https://gist.github.com/WorldShredder/be7cd4d6dcf9ca1057e3e0310b73603e)
    - [Tmux Bindings (not yet documented)]()
- FZF
- Zoxide
- Eza (Includes `ezg` alias)
- FD
- Golang

## Resources

- [Tmux Installer](https://github.com/worldshredder/tmux-installer)
- [Go Installer](https://gist.github.com/WorldShredder/726c1add8067556a17a431fdd60517f0)
- [Tmux Setup Instructions](https://gist.github.com/WorldShredder/8fb23f07bc4348a9740eb4f207b9c06c)

## Todo

- [ ] Implement proper cleanup step in trap
- [ ] Allow script execution with sudo (requires `sudo -u __USER__` scheme)
- [ ] Add install steps for NeoVim
- [ ] Language environments
    - [ ] Python
    - [ ] Lua
    - [ ] PHP
    - [ ] Javascript/Node
    - [ ] Rust
    - [ ] C
- [ ] Bunch of other stuff...
