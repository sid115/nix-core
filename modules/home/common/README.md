The common module sets some opinionated defaults. It is recommended to import it in your Home Manager configuration as some nix-core modules may depend on it:

```nix
{ inputs, ... }:

{
  imports = [
    inputs.core.homeModules.common
  ];
}
```
