# Device

This module lets you set some defaults for a device type. Available devices are:

- laptop
- vm

To enable these defaults, you need to import this module in your host configuration. For example:

```nix
# hosts/HOSTNAME/default.nix

imports = [ inputs.core.nixosModules.device.vm ]; # this imports all defaults for VMs. See `vm.nix`
```
