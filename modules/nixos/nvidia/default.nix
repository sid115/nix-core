{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkDefault;
in
{
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.extraModulePackages = [ config.hardware.nvidia.package ];
  boot.initrd.kernelModules = [ "nvidia" ];

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.open = false;
  hardware.nvidia.package = mkDefault config.boot.kernelPackages.nvidiaPackages.latest;

  nixpkgs.config.cudaSupport = true;

  services.xserver.videoDrivers = [ "nvidia" ];
}
