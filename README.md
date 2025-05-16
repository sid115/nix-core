# nix-core

The goal of this repository is to provide modules and packages for your NixOS and Home Manager configurations for client and server applications. Scripts are provided to automate the creation and installation of your own flake.

Currently, only `x86_64` is supported. `aarch64` is in an experimental state.

## Directory Structure

This is the directory structure of this repository:

```
.
├── apps
├── docs
├── lib
├── modules
│   ├── home
│   └── nixos
├── overlays
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
- `lib`: custom Nix functions
- `modules/home`: Home Manager modules
- `modules/nixos`: NixOS modules
- `overlays`: fixes for packages
- `pkgs`: custom packages
- `templates/dev`: development templates
- `templates/nix-config`: kickstart your first nix-config flake
- `CONTRIBUTING.md`: contribution guide
- `README.md`: this file
- `flake.nix`: entry point

For more information, check out the `README.md` file in each module's directory.

## Getting started

The following guides will take you from scratch to a working configuration.

### 1. Install the Nix package manager

Follow the [official installation instructions](https://nixos.org/download/) to install the Nix package manager on your system.

### 2. Create your own nix-config flake

Create an empty directory and apply the [nix-config template](./templates/nix-config) to it:

```bash
mkdir -p ~/.config/nixos
cd ~/.config/nixos
nix flake init -t "github:sid115/nix-core#templates.nix-config"
```

> Note: You do not have to use `~/.config/nixos`, but configuration related scripts in this repository will use this directory as the default nix-config flake directory.

### 3. Add NixOS and Home Manager configurations

Follow the [configuration creation guide](./docs/create_config.md) to add new NixOS and Home Manager configurations to your nix-config flake.

This process can be repeated for as many configurations you need. Push your changes to your remote nix-config git repository.

You might want to take a look at [my personal configuration](https://github.com/sid115/nix-config) to see how I use nix-core in my nix-config repository.

### 4. Installation Guide

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

`TEMPLATE` has to be the template attribute, for example `c-hello` or `nix-config`. See [flake.nix](./flake.nix) for all available templates.

## Contributing

Please see the [CONTRIBUTING.md](./CONTRIBUTING.md) file.
