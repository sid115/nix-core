# Virtualisation

Virtualisation using QEMU via libvirt and managed through Virt-manager with VFIO support.

## Overview

1. **QEMU** is the hypervisor that provides the core virtualisation capabilities.
1. **libvirt** is a toolkit and API that manages virtualisation platforms, such as QEMU.
1. **Virt-manager** is a GUI tool that interacts with libvirt to manage VMs.
1. **virsh** is a CLI tool that interacts with libvirt to manage VMs.

## Docs

### QEMU

- [Official docs](https://www.qemu.org/docs/master/)

### libvirt

- [Official docs](https://libvirt.org/docs.html)
- [Arch Wiki](https://wiki.archlinux.org/title/Libvirt)
- [virsh CLI](https://www.libvirt.org/manpages/virsh.html)

> If you are using the [Home Manager module](../../home/virtualisation/README.md) as well, then `virsh` is aliased to `virsh --connect qemu:///system`

### Virt-manager

- [GitHub Repository](https://github.com/virt-manager/virt-manager)
- [NixOS Official Wiki](https://wiki.nixos.org/wiki/Virt-manager)
- [NixOS Community Wiki](https://nixos.wiki/wiki/Virt-manager)
- [Arch Wiki](https://wiki.archlinux.org/title/Virt-manager)

## Setup

1. Import this module in your NixOS config. It is recommended to use the [Virtualisation Home Manager module](../../home/virtualisation/README.md) as well.
1. Add your user to the `libvirtd` group: `users.users.YOU.extraGroups = [ "libvirtd" ];`
1. Rebuild and reboot: `rebuild all && sudo reboot now`
