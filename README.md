# nix-core

The goal of this repository is to provide modules and packages for your NixOS and Home Manager configurations for client and server applications. Scripts are provided to automate the creation and installation of your own flake.

Currently, only `x86_64` is supported. `aarch64` is in an experimental state.

## Directory Structure

This is the directory structure of this repository:

```
.
├── apps
│   ├── create       # Add new hosts to your nix-config flake
│   └── install      # NixOS installation script
├── docs             # Documentation hosted on GH Pages
├── modules
│   ├── home         # Home Manager modules
│   └── nixos        # NixOS modules
├── overlays         # Fixes for and additional packages
├── pkgs             # Custom Nix packages
├── templats
│   ├── dev          # Development templates
│   └── nix-config   # Create your first nix-config flake
└── CONTRIBUTING.md  # Contribution guide
```

## Getting started

Please refer to our documentation hosted on [GitHub Pages](https://sid115.github.io/nix-core/).

The Getting Started guide will take you from scratch to a working configuration.

## Rebuilding

To rebuild the system and/or user configurations after making changes to them, run the `rebuild` script:

```
Wrapper script for 'nixos-rebuild switch' and 'home-manager switch' commands.
Usage: rebuild <command> [OPTIONS]

Commands:
  nixos                Rebuild NixOS configuration
  home                 Rebuild Home Manager configuration
  all                  Rebuild both NixOS and Home Manager configurations
  help                 Show this help message

Options (for NixOS and Home Manager):
  -H, --host <host>    Specify the hostname (as in 'nixosConfiguraions.<host>'). Default: $(hostname)
  -p, --path <path>    Set the path to the flake directory. Default: ~/.config/nixos
  -U, --update         Update flake inputs
  -r, --rollback       Don't build the new configuration, but use the previous generation instead
  -t, --show-trace     Show detailed error messages

NixOS only options:
  -B, --build-host <user@example.com>     Use a remote host for building the configuration via SSH
  -T, --target-host <user@example.com>    Deploy the configuration to a remote host via SSH. If '--host' is specified, it will be used as the target host.

Home Manager only options:
  -u, --user <user>    Specify the username (as in 'homeConfigurations.<user>@<host>'). Default: $(whoami)
```

Use the environment variable `NIX_SSHOPTS` to pass additional options to ssh. SSH target specifications for `-B` and `-T` are compatible with your SSH configuration. You can use the Home Manager option [`programs.ssh.matchBlocks`](https://home-manager-options.extranix.com/?query=programs.ssh.matchBlocks&release=master) to specify per-host settings.

> [!TIP]
> Check a remote system's current generation with: `ssh user@your-server "readlink /run/current-system"`

## Templates

This repository provides some templates for [software development](./templates/dev/) and your own [nix-config flake](./templates/nix-config/). Create an empty directory to initialize the template in.

```bash
mkdir DIR
cd DIR
nix flake init -t "github:sid115/nix-core#templates.TEMPLATE"
```

`TEMPLATE` has to be the template attribute, for example `c-hello` or `nix-config`. See [flake.nix](./flake.nix) for all available templates.

## Contributing

Please see the [CONTRIBUTING.md](./CONTRIBUTING.md) file.
