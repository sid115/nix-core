# nix-core

The goal of this repository is to provide modules and packages for your NixOS and Home Manager configurations for client and server applications. Scripts are provided to automate the creation and installation of your own flake.

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
│   ├── dev
│   └── nix-config
├── CONTRIBUTING.md
├── README.md
└── flake.nix
```

- `apps`: executables exposed through `nix run`
- `docs`: documentation
- `modules/home`: Home Manager modules
- `modules/nixos`: NixOS modules
- `pkgs`: custom packages
- `templates/dev`: development templates
- `templates/nix-config`: templates to kickstart your first nix-config
- `CONTRIBUTING.md`: contribution guide
- `README.md`: this file
- `flake.nix`: entry point

For more information, check out the `README.md` file in each module's directory.

## Getting started

The following guides will take you from scratch to a working configuration.

### 1. Create your own nix-config flake

Follow the [nix-config flake creation guide](./docs/create_flake.md) to create your own flake from one of the [nix-config templates](./templates/nix-config/).

You might want to take a look at [my personal configuration](https://github.com/sid115/nix-config) to see how I use nix-core in my nix-config repository.

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

## Templates

This repository provides some templates for [software development](./templates/dev/) and your own [nix-config flake](./templates/nix-config/). Create an empty directory to initialize the template in.

```bash
mkdir DIR
cd DIR
nix flake init -t "github:sid115/nix-core#templates.TEMPLATE"
```

`TEMPLATE` has to be the template attribute, for example `dev.c-hello` or `nix-config.hyprland`. See [flake.nix](./flake.nix) for all available templates. Read more about our nix-config templates [here](./docs/create_flake.md).

## Contributing

Please see the [CONTRIBUTING.md](./CONTRIBUTING.md) file.
