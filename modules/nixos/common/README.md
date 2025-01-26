The common module sets some opinionated defaults. It is recommended to import it into your NixOS configuration:

```nix
{ inputs, ... }:

{
  imports = [
    inputs.core.nixosModules.common
  ];
}
```
