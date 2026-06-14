<h1 align=center>WS-ENV</h1>
<h3 align=center>Developer Workstation Setup</h3>
<br>

**WS-Env** is a personal collection of modular installation scripts for developer workstations that uses the [Planit](https://github.com/worldshredder/planit) framework to better handle failures during a lengthy install. _Bash4 is required._

### Compatibility

#### System

- Debian 14 _(tested)_
- Fedora 43 _(tested)_

#### Shells

> [!NOTE]
> This only applies if you plan on letting **WS-Env** configure your shell runtime configs with `-s|--shell`

- Bash
- Zsh

## Install

1. #### Clone the repository

    ```sh
    git clone https://github.com/worldshredder/ws-env && cd ws-env/src
    ```

2. #### Run the installer

    ```sh
    # Recommended options for a fresh install
    ./install --shell bash,zsh --extras --purge --binstall
    ```

    For installer and library options, see `--help` or `--help all`:

    ```sh
    ./install --help all
    ```

    To list available libraries, see `--list`:

    ```sh
    ./install --list
    ```

## Examples

> [!IMPORTANT]
> In almost all cases you will want to specify your shell with the `-s|--shell` option, e.g., `--shell bash,zsh`. If you do not specify a shell, **ws-env** will skip configuring shell runtime configs and would require manual configuration.

#### Full install

> [!NOTE]
> In most cases it is recommended that you use `--purge` to avoid conflicts with newly installed software. It is also recommended that `--binstall` be passed to avoid dependency issues when building Rust crates.

```sh
./install -s bash --purge --extras --binstall
```

#### Full install (no dotfiles)

If you want everything except [Worldshredder's dotfiles](https://github.com/worldshredder/dotfiles), you can exclude it with `-L`:

```sh
./install -s bash -L dotfiles --purge --extras --binstall
```

#### Dotfile-centric install

> [!NOTE]
> Most [Worldshredder dotfile modules](https://github.com/worldshredder/dotfiles/tree/main/lib) require a Nerdfont. If you do not already have one installed, it is recommended that you include the `nerdfonts` library and specify your desired font(s) with `--nerdfonts-font`.

If you only want [Worldshredder's dotfiles](https://github.com/worldshredder/dotfiles) and their dependencies, you can specify the library with `-l|--lib`:

```sh
./install -s bash -l dotfiles --purge --extras --binstall
```

Or if you the dotfiles only, you can exclude the library's dependencies with `-R|--skip-required`:

```sh
# dotfiles does not have any extras and does not require purging
./install -l dotfiles,nerdfonts -R dotfiles --nerdfonts-font jetbrainsmono
```

Or if you want a very specific [dotfiles module](https://github.com/WorldShredder/dotfiles/tree/main/lib), you can specify it with `--dotfiles-lib`:

```sh
./install -l dotfiles,nerdfonts -R dotfiles --dotfiles-lib ps1,nvim --nerdfonts-font jetbrainsmono
```

#### Nerdfonts only

You can list available Nerdfonts with `--nerdfonts-list`:

```sh
./install -l nerdfonts --nerdfonts-list
```

Specify your desired fonts with `--nerdfonts-font` as a comma-separated list:

```sh
./install -l nerdfonts --nerdfonts-font jetbrainsmono,robotomono,mononoki
```
