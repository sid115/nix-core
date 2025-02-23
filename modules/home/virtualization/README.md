# Virtualization

Home Manager module to go with the [Virtualization NixOS module](../../nixos/virtualization/README.md).

## Setup

1. Import this module in your Home Manager configuration and the corresponding [NixOS module](../../nixos/virtualization/README.md) in your NixOS configuration.
1. Rebuild and reboot: `rebuild all && sudo reboot now`
1. Start the default network: `virsh net-autostart default`
