{ pkgs, lib, ... }:

{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";
}
