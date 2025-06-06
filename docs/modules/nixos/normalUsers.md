# Normal Users

This module automates user creation for normal users.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/normalUsers).

## Config

For example:

```nix
imports = [ inputs.core.nixosModules.normalUsers ]

config.normalUsers = {
  alice = {
    extraGroups = [ "wheel" ];
    sshKeyFiles = [ ../../users/alice/pubkeys/id_rsa.pub ];
  };
};
```
