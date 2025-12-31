{
  inputs,
  outputs,
  ...
}:

{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./networking.nix
    ./packages.nix
    ./services
    ./users.nix

    inputs.core.nixosModules.common

    outputs.nixosModules.common
  ];

  system.stateVersion = "25.11";
}
