The common module sets some opinionated defaults. It is recommended to import it into your Home Manager configuration:

```nix
{ inputs, ... }:

{
  imports = [
    inputs.core.homeModules.common
  ];
}
```
