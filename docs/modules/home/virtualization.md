# Virtualization

Home Manager module to go with the [Virtualization NixOS module](../nixos/virtualization.md).

View the [*nix-core* Home Manager module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/home/virtualization).

## Setup

1. Import this module in your Home Manager configuration and the corresponding [NixOS module](../nixos/virtualization.md) in your NixOS configuration.
1. Rebuild and reboot: `rebuild all && sudo reboot now`
1. Start the default network: `virsh net-autostart default`
