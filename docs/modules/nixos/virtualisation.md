# Virtualisation

Virtualisation using QEMU via libvirt and managed through Virt-manager with VFIO support.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/virtualisation).

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

> If you are using the [Home Manager module](../home/virtualisation.md) as well, then `virsh` is aliased to `virsh --connect qemu:///system`

### Virt-manager

- [GitHub Repository](https://github.com/virt-manager/virt-manager)
- [NixOS Official Wiki](https://wiki.nixos.org/wiki/Virt-manager)
- [NixOS Community Wiki](https://nixos.wiki/wiki/Virt-manager)
- [Arch Wiki](https://wiki.archlinux.org/title/Virt-manager)

## Setup

1. Import this module in your NixOS config. It is recommended to use the [Virtualisation Manager module](../home/virtualisation.md) as well.
1. Add your user to the `libvirtd`, `qemu-libvirtd` and `kvm` group:
    ```nix
    users.extraGroups.libvirtd.members = [ "<you>" ];
    users.extraGroups.qemu-libvirtd.members = [ "<you>" ];
    users.extraGroups.kvm.members = [ "<you>" ];
    ```
1. Rebuild and reboot: `rebuild all && sudo reboot now`
1. Enable and start the default network and reboot again: `virsh net-autostart default && virsh net-start default`

## VFIO

### Setup

For successful PCI device passthrough, devices must be properly isolated by IOMMU groups. A device can be safely passed through if:
- It is the **only device** in its IOMMU group (recommended), OR
- **All devices** in its IOMMU group are passed through together

This module includes an `iommu-groups` command to help identify IOMMU groups:

```bash
iommu-groups
```

In this example, IOMMU group 9 contains only the Nvidia GPU which will get passed to the VM:

```
IOMMU Group 9 01:00.0 3D controller [0302]: NVIDIA Corporation TU117M [GeForce GTX 1650 Mobile / Max-Q] [10de:1f9d] (rev a1)
```

Take not of the PCI device ID. In this case: `10de:1f9d`.

### Config

This is an example with the Nvidia GPU above:

```nix
{ inputs, ... }:

{
  imports = [ inputs.core.nixosModules.virtualisation ];

  virtualisation = {
    vfio = {
      enable = true;
      IOMMUType = "amd";
      devices = [
        "10de:1f9d"
      ];
      blacklistNvidia = true;
    };
    hugepages.enable = true;
  };
}
```

### Virt Manager

#### 1. Open VM Hardware Settings

- Select your VM in Virt Manager
- Click *"Show virtual hardware details"*

#### 2. Add PCI Host Device

- Click *"Add Hardware"* button at bottom
- Select *"PCI Host Device"* from the list
- Click *"Finish"*

You may repeat this process for as many devices as you want to add to your VM.

### Looking Glass

TODO

### Troubleshooting

#### Check Kernel Parameters

View current kernel parameters:

```bash
cat /proc/cmdline
```

Check VFIO-related parameters:

```bash
dmesg | grep -i vfio
```

Verify IOMMU is enabled:

```bash
dmesg | grep -i iommu
```

#### Verify device binding

```bash
lscpi -k
```

Look for your device you want to pass through. It should say:

```
Kernel driver in use: vfio-pci
```

For example:

```
01:00.0 3D controller: NVIDIA Corporation TU117M [GeForce GTX 1650 Mobile / Max-Q] (rev a1)
	Subsystem: Lenovo Device 380d
	Kernel driver in use: vfio-pci
	Kernel modules: nvidiafb, nouveau
```

#### Verify module status

Ensure blacklisted modules are not loaded:

```bash
lsmod | grep nvidia
lsmod | grep nouveau
```

These should return nothing.

#### `vfio-pci.ids` not appearing

Check generated bootloader config:

```bash
cat /boot/loader/entries/nixos-*.conf
```
