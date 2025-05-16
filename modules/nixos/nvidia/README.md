# Nvidia

NixOS module that configures your Nvidia GPU with proprietary drivers.

> Tested on Turing and Ampere. Should work with most modern Nvidia GPUs.

## Setup

Import this module inside your NixOS configuration:

```
imports = [ inputs.core.nixosModules.nvidia ];
```

## Config

Set the Nvidia package with `hardware.nvidia.package`. The default ist:

```nix
hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
```
