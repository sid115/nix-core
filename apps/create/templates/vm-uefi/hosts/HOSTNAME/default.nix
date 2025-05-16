{ inputs, outputs, ... }:

{
  imports = [
    inputs.core.nixosModules.common
    inputs.core.nixosModules.normalUsers
    inputs.core.nixosModules.openssh

    outputs.nixosModules.common

    ./boot.nix
    ./hardware.nix
    ./packages.nix
  ];

  networking.hostName = "HOSTNAME";

  normalUsers = {
    USERNAME = {
      name = "USERNAME";
      extraGroups = [
        "wheel"
      ];
      # sshKeyFiles = [ ../../users/USERNAME/pubkeys/YOUR_PUBKEY.pub ]; # FIXME: Set your pubkey
    };
  };

  system.stateVersion = "24.11";
}
