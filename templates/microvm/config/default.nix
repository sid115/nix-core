{ inputs, ... }:

{
  imports = [
    inputs.microvm.nixosModules.microvm

    ./base.nix
    ./configuration.nix
  ];
}
