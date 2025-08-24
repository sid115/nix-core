# Common

The common module sets some opinionated defaults.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/common).

It is recommended to import it in your NixOS configuration as some nix-core modules may depend on it:

```nix
{ inputs, ... }:

{
  imports = [
    inputs.core.nixosModules.common
  ];
}
```
