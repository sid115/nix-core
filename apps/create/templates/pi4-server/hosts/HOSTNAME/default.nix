{ inputs, outputs, ... }:

{
  imports = [
    inputs.core.nixosModules.common
    inputs.core.nixosModules.nginx
    inputs.core.nixosModules.normalUsers
    inputs.core.nixosModules.openssh

    outputs.nixosModules.common

    ./boot.nix
    ./hardware.nix # care! take always the one from temples. don't generate a new one!
    ./packages.nix
  ];

  networking.hostName = "HOSTNAME";

  services = {
    openssh.enable = true;
  };

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
