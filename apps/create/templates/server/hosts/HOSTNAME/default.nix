{ inputs, outputs, ... }:

{
  imports = [
    inputs.core.nixosModules.common
    inputs.core.nixosModules.nginx
    inputs.core.nixosModules.normalUsers
    inputs.core.nixosModules.openssh

    outputs.nixosModules.common

    ./boot.nix
    ./hardware.nix # will be generated during installation
    ./packages.nix
  ];

  networking.hostName = "HOSTNAME";

  services = {
    nginx.enable = true;
  };

  normalUsers = {
    USERNAME = {
      extraGroups = [
        "wheel"
      ];
      # sshKeyFiles = [ ../../users/USERNAME/pubkeys/YOUR_PUBKEY.pub ]; # FIXME: Set your pubkey
    };
  };

  system.stateVersion = "25.05";
}
