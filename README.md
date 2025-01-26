# nix-core

The goal of this repository is to provide modules and packages for your NixOS and Home Manager configurations for client and server applications. Scripts are provided to automate the creation and installation of your own flake.

You might want to take a look at [my personal configuration](https://github.com/sid115/nix-config) to see how nix-core might be used in a flake.

## Directory Structure

This is the directory structure of this repository:

```
.
├── apps
├── docs
├── modules
│   ├── home
│   └── nixos
├── pkgs
├── templates
│   ├── hyprland
│   └── server
├── CONTRIBUTING.md
├── README.md
└── flake.nix
```

- `apps`: executables exposed through `nix run`
- `docs`: documentation
- `modules/home`: Home Manager modules
- `modules/nixos`: NixOS modules
- `pkgs`: local packages
- `templates`: NixOS and Home Manager configuration templates
- `templates/hyprland`: Hyprland configuration template
- `templates/server`: Minimal server configuration template
- `CONTRIBUTING.md`: contribution guide
- `README.md`: this file
- `flake.nix`: entry point

For more information, check out the `README.md` file in each module's directory.

## Getting started

This guide will take you from scratch to a working configuration based on one of the available [templates](./templates).

### 1. Create your own flake

You need to have the Nix package manager installed. If you have not done so already, follow the [official installation instructions](https://nixos.org/download/).

Run the [`create` script](./apps/create/create.sh) to initialize your desired template:

```bash
nix --experimental-features "nix-command flakes" run github:sid115/nix-core#apps.x86_64-linux.create -- \
-t TEMPLATE \
-u USERNAME \
-H HOST \
--git-name GIT_NAME \
--git-email GIT_EMAIL \
-d ~/.config/nixos
```

> Change the architecture if needed. Supported architectures are listet under `supportedSystems` inside [`flake.nix`](./flake.nix).

See the script's help page for reference:

```
Usage: $0 -u|--user USERNAME -H|--host HOSTNAME -d|--directory PATH/TO/EMPTY/DIRECTORY -t|--template TEMPLATE [--git-name GIT_NAME] [--git-email GIT_EMAIL]

Options:
    -u, --user USERNAME        Specify the username (mandatory)
    -H, --host HOSTNAME        Specify the hostname (mandatory)
    -d, --directory DIRECTORY  Path to an empty directory (mandatory)
    -t, --template TEMPLATE    Template to use for nix flake init (mandatory)
    --git-name GIT_NAME        Specify the git name (optional, default: USERNAME)
    --git-email GIT_EMAIL      Specify the git email (optional, default: USERNAME@HOSTNAME)
    -h, --help                 Show this help message
```

If you are already on your target machine running NixOS, it is recommended that you set the directory to `~/.config/nixos`, as the `rebuild` script (see below) expects your configuration in this directory.

All templates work right out of the box. You only need to edit the disk partitioning script (`disks.sh`) or provide a [disko](https://github.com/nix-community/disko) configuration (`disko.nix`) in your host directory. A basic single disk partitioning script is provided. Set your disk by its ID, which comes from `ls -lAh /dev/disk/by-id`. When you are happy with your configuration, create a public Git repository to pass to the installation script (see below).

If you like, you can lock your flake before committing by running:

```bash
nix --experimental-features "nix-command flakes" flake lock
```

### 2. Installation Guide

Follow the [installation instructions](./docs/install_instructions.md) to install an existing configuration. The hardware configuration can be generated automatically during installation.

## Rebuilding

To rebuild the system and/or user configurations after making changes to them, run the `rebuild` script:

```
Usage: rebuild <command> [OPTIONS]

Commands:
  nixos                Rebuild NixOS configuration
  home                 Rebuild Home Manager configuration
  all                  Rebuild both NixOS and Home Manager configurations

Options:
  -H, --host <host>    Specify the host (for NixOS and Home Manager). Default: $(hostname)
  -u, --user <user>    Specify the user (for Home Manager only). Default: $(whoami)
  -p, --path <path>    Set the path to the flake directory. Default: ~/.config/nixos
  -U, --update         Update flake inputs
  -r, --rollback       Don't build the new configuration, but use the previous generation instead
  -t, --show-trace     Show detailed error messages
  -h, --help           Show this help message
```

## Contributing

Please see the [CONTRIBUTING.md](./CONTRIBUTING.md) file.
