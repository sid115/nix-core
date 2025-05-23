# Nvidia

NixOS module that configures your Nvidia GPU with proprietary drivers.

> Tested on Turing and Ampere. Should work with most modern Nvidia GPUs.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/nvidia).

## Setup

Import this module inside your NixOS configuration:

```
imports = [ inputs.core.nixosModules.nvidia ];
```

## Config

Set the Nvidia package with `hardware.nvidia.package`. The default ist:

```nix
imports = [ inputs.core.nixosModules.nvidia ];

hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
```
