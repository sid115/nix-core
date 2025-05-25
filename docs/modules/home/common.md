# Common

The common module sets some opinionated defaults.

View the [*nix-core* Home Manager module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/home/common).

It is recommended to import it in your Home Manager configuration as some nix-core modules may depend on it:

```nix
{ inputs, ... }:

{
  imports = [
    inputs.core.homeModules.common
  ];
}
```
