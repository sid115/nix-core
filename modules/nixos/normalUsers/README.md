# Normal Users

This module automates user creation for normal users.

## Config

For example:

```nix
imports = [ inputs.core.nixosModules.normalUsers ]

config.normalUsers = {
  sid = {
    name = "sid";
    extraGroups = [ "wheel" ];
    sshKeyFiles = [ ../../users/sid/pubkeys/id_rsa.pub ];
  };
};
```
