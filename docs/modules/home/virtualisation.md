# Virtualisation

Home Manager module to go with the [Virtualisation NixOS module](../nixos/virtualisation.md).

View the [*nix-core* Home Manager module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/home/virtualisation).

## Setup

1. Import this module in your Home Manager configuration and the corresponding [NixOS module](../nixos/virtualisation.md) in your NixOS configuration.
1. Rebuild and reboot: `rebuild all && sudo reboot now`
1. Start the default network: `virsh net-autostart default`
