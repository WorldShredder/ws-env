<h1 align=center>WS-ENV</h1>
<h3 align=center>Developer Workstation Setup</h3>
<br>

**WS-Env** is a personal collection of modular installation scripts for developer workstations, and written using the [Planit](https://github.com/worldshredder/planit) framework to better handle failures during a lengthy install.

> [!IMPORTANT]
> Tested in latest _debian_ and _fedora_ Qubes templates.

## Install

1. #### Clone the repository

    ```sh
    git clone https://github.com/worldshredder/ws-env && cd ws-env/src
    ```

2. #### Run the installer

    ```sh
    ./install --shell bash,zsh
    ```

    For installer and library options, see `--help`

    ```sh
    ./install --help
    ```
