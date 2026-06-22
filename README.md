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

## Basic Install

1. #### Clone the repository

    ```sh
    git clone https://github.com/worldshredder/ws-env && cd ws-env/src
    ```

2. #### Run the installer

    ```sh
    # Recommended options for a fresh install
    ./install --shell bash,zsh --extras --purge --binstall
    ```

    For installer and module options, see `--help` or `--help all`:

    ```sh
    ./install --help all
    ```

    To list available modules, see `--list`:

    ```sh
    ./install --list
    ```

## Advanced Install

**WS-Env** provides several options that allow you to tailor the installation to your needs. See `./install --help all` for a full list of options.

#### Whitelist & Blacklist

You can specify the modules you want to install with the `-l|--lib` option (whitelist) or you can exclude modules using the `-L|--exclude` option (blacklist). The latter option overrides module dependencies defined in `require.conf` config files.

#### Shell Configuration

**WS-Env** will configure compatible shell configs when they are passed using the `-s|--shell` option, e.g., `--shell bash,zsh`. If you do not specify a shell you'll need to configure your shell runtime configs manually (not documented here).

#### Dependency Management

**WS-Env** modules that depend on the installation of other modules define their dependencies in a `require.conf` file. This ensures necessary installation steps occur when passing a whitelist with the `--lib` option.

> [!IMPORTANT]
> Some modules do not define _option-specific_ dependencies and require that you include these dependencies when using the `--lib` option.
>
> For example, the _zoxide_ module can be installed via `cargo` (default) or via the system package manager, which means the _rust_ module is a soft requirement and not included in the _zoxide_ module's `require.conf`. As such, the _rust_ module must be included in the `--lib` whitelist when installing _zoxide_ via `cargo`.
>
> Future versions of **WS-Env** will resolve this issue by improving the `require.conf` syntax.

#### Version Pinning

All modules provide one or more ways to the installation to a specific version or identifier, such as a git tag. Doing so ensures that repeated installs across multiple instances remain consistent and helps to avoid unexpected buggy software releases.

You can find out which methods are available for a given module by running:

```sh
./install --help MODULE_NAME
```

> [!NOTE]
> Version pinning does not apply to installs using `--pkgman` except for _lua_ on Debian systems.

- #### Github Sourced Modules

    Modules which source from Github will accept either a git _tag_ or _commit sha_ via the `--{MODULE_NAME}-tag` and `--{MODULE_NAME}-commit` options.

    If the module can be installed as a crate, passing the desired version with `--{MODULE}-version` (typically the git _tag_ without the _"v"_ prefix) will instruct `cargo` to install the crate using the binary install feature. This requires _rust_ extras if `binstall` is not already installed on the system.

- #### Non-Github Sourced Modules

    Modules which source directly from the vendor -- such as _golang_, _lua_ and _node_ -- will accept a version associated with either a download link or version manager like [NVM](https://www.nvmnode.com/) via the `--{MODULE_NAME}-version` option.

### Full Install

In most cases it is recommended that you use `--purge` to ensure the removal of target modules and avoid pathing and version conflicts. It is also recommended that you pass the `--binstall` option (rust only) to avoid having to build crates which may cause build-dependency issues on some systems.

```sh
./install -s bash --purge --extras --binstall
```

### Core Install (no dotfiles)

If you want everything except [Worldshredder's dotfiles](https://github.com/worldshredder/dotfiles), you can exclude it with `-L`:

```sh
./install -s bash -L dotfiles --purge --extras --binstall
```

### Dotfile-Centric Install

> [!NOTE]
> Most [Worldshredder dotfile modules](https://github.com/worldshredder/dotfiles/tree/main/lib) require a Nerdfont. If you do not already have one installed, it is recommended that you include the `nerdfonts` module and specify your desired font(s) with `--nerdfonts-fonts`.

If you only want [Worldshredder's dotfiles](https://github.com/worldshredder/dotfiles) and their dependencies, you can specify the module with `-l|--lib`:

```sh
./install -s bash -l dotfiles --purge --extras --binstall
```

Or if you the dotfiles only, you can exclude the module's dependencies with `-R|--skip-required`:

```sh
# dotfiles does not have any extras and does not require purging
./install -l dotfiles,nerdfonts -R dotfiles --nerdfonts-fonts jetbrainsmono
```

Or if you want a very specific [dotfiles module](https://github.com/WorldShredder/dotfiles/tree/main/lib), you can specify it with `--dotfiles-lib`:

```sh
./install -l dotfiles,nerdfonts -R dotfiles --dotfiles-lib ps1,nvim --nerdfonts-fonts jetbrainsmono
```

### Nerdfonts Only

You can list available Nerdfonts with `--nerdfonts-list`:

```sh
./install -l nerdfonts --nerdfonts-list
```

Specify your desired fonts with `--nerdfonts-fonts` as a comma-separated list:

```sh
./install -l nerdfonts --nerdfonts-fonts jetbrainsmono,robotomono,mononoki
```
