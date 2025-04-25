{ inputs, outputs, ... }:

{
  imports = [
    inputs.core.nixosModules.common
    inputs.core.nixosModules.hyprland
    inputs.core.nixosModules.normalUsers
    inputs.core.nixosModules.openssh
    inputs.core.nixosModules.pipewire

    outputs.nixosModules.common

    ./boot.nix
    ./hardware.nix # will be generated during installation
    ./packages.nix
  ];

  networking.hostName = "HOSTNAME";

  services = {
    openssh.enable = true;
    pipewire.enable = true;
  };

  normalUsers = {
    USERNAME = {
      name = "USERNAME";
      extraGroups = [
        "audio"
        "floppy"
        "input"
        "lp"
        "networkmanager"
        "video"
        "wheel"
      ];
      # sshKeyFiles = [ ../../users/USERNAME/pubkeys/YOUR_PUBKEY.pub ]; # FIXME: Set your pubkey
    };
  };

  system.stateVersion = "24.11";
}
