# Virtualisation

Home Manager module to go with [our Virtualisation NixOS module](../../nixos/virtualisation/README.md).

## Setup

1. Import this module in your Home Manager configuration and the corresponding [NixOS module](../../nixos/virtualisation/README.md) in your NixOS configuration.
1. Rebuild and reboot: `rebuild all && sudo reboot now`
1. Start the default network: `virsh net-autostart default`
