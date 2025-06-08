# NixOS

NixOS is a Linux distribution built entirely on top of the Nix package manager and the Nix language. This means your entire operating system, from the kernel to user-space applications and system services, is declared in a set of Nix expressions. This brings all the benefits of Nix (reproducibility, atomic upgrades, easy rollbacks) to your whole system.

## NixOS Configuration (with Flakes)

With flakes, your NixOS configuration typically resides in a `flake.nix` file that exports a `nixosConfigurations` output.

Let's have a look at a basic `flake.nix` for a NixOS machine.

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self, # The flake itself
      nixpkgs, # The nixpkgs input
      ...
    }@inputs: # `self` and `nixpkgs` are available under `inputs`
    let
      inherit (self) outputs;
    in
    {
      # Define NixOS configurations
      nixosConfigurations = {
        # Name for this specific system configuration
        your-pc = nixpkgs.lib.nixosSystem {
          # Arguments passed to all NixOS modules
          specialArgs = {
            inherit inputs outputs;
          };
          # List of all configuration files (modules)
          modules = [ ./configuration.nix ];
        };
      };
    };
}
```

The `nixosSystem` function takes a list of `modules`. Each module is a Nix expression that defines desired system state and settings. So the actual system configuration lives in `configuration.nix`:

```nix
# configuration.nix
{ config, pkgs, ... }: # The arguments provided to a NixOS module

{
  # Enable a display manager and desktop environment
  services.displayManager.lightdm.enable = true;
  services.desktopManager.gnome.enable = true; # Or kde, xfce, etc.

  # List of packages to be installed globally
  environment.systemPackages = with pkgs; [
    firefox
    neovim
    git
  ];

  # Configure networking
  networking.hostName = "my-nixos-desktop";

  # Users
  users.users.Alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Add user to groups for sudo and network management
    initialPassword = "changeme"; # Set a temporary password
  };

  # Set system-wide locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Set the system time zone
  time.timeZone = "America/New_York";

  # ... many more options ...
}
```

> Please note that the above configuration is not a complete working NixOS configuration. It just showcases how to you can define your system declaratively.

The `config` argument is the *evaluated* final configuration of your system. You use it to refer to other parts of your configuration. For example, you might make one service depend on another's path: 

```nix
myService.dataPath = config.services.otherService.dataPath;
```

It's primarily used for referencing options *within* the configuration.

## The Module System

NixOS uses a powerful *module system*. A module is a Nix expression that declares:
- **`options`**: What configurable parameters this module exposes.
- **`config`**: How this module sets those parameters (and potentially other system parameters).
- **`imports`**: Other modules to include.

When you build your NixOS configuration using `nixos-rebuild switch --flake path/to/flake/directory#your-pc`, NixOS collects all the options and configurations from all activated modules, merges them, and then builds a new system closure in the Nix store.

## Searching NixOS Options

There are thousands of options in NixOS. You can search them in the [NixOS Options Search](https://search.nixos.org/options?channel=unstable).

For example, search for `services.desktopManager` to list all options regarding desktop managers.

## Home Manager

While NixOS manages system-wide configurations, **Home Manager** applies the power of Nix to your *user-specific* configuration files and dotfiles. Instead of manually symlinking dotfiles or writing install scripts, you define your user environment declaratively in Nix. Home Manager applies Nix's declarative power to the user space, much like NixOS does for the system space.

Let's extend our `flake.nix`:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        your-pc = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./configuration.nix ];
        };
      };

      homeConfigurations = {
        your-user = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./home.nix ];
        };
      };
    };
}
```

`home.nix` might look like this:

```nix
# home.nix
{ config, pkgs, ... }:

{
  # Define your user's home directory
  home.username = "youruser";
  home.homeDirectory = "/home/youruser";

  # Install user-specific packages
  home.packages = with pkgs; [
    htop
    cowsay
  ];

  # Configure zsh
  programs.zsh.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.plugins = [ "git" "history" ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };

  # ... many more options for things like VS Code, Tmux, themes, fonts etc.
}
```

You could now build your Home Manager configuration with `home-manager switch --flake path/to/flake/directory#your-user`.

Search for Home Manager options in the [Home Manager Options Search](https://home-manager-options.extranix.com/?release=master).

## What nix-core does

The [`nix-core` repository](https://github.com/sid115/nix-core) attempts to automate your NixOS and Home Manager experience. It exposes NixOS and Home Manager modules that sit on top of the already existing modules in NixOS and Home Manager respectively. Module options are added and opinionated defaults are set to get your configuration running with less configuration options needed to be set.

Create your NixOS and Home Manager configuration flake (we call that `nix-config`) with nix-core as an input using a template provided in the repository. Adding NixOS and Home Manager configurations is automated through a shell script. You can choose between some configuration templates for server or client systems. The installation process is automated through a shell script as well. Also, an installation guide is provided. Rebuilding your NixOS and Home Manager configurations is wrapped in nix-core's rebuild script.

The [Getting Started Guide](../getting-started/create-nix-config.md) will take you from nothing to a working NixOS configuration using nix-core.
