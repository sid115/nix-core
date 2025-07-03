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
