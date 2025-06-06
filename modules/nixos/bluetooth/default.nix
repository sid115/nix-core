{ lib, pkgs, ... }:

let
  inherit (lib) mkDefault;
in
{
  hardware.bluetooth.enable = mkDefault true;
  hardware.bluetooth.powerOnBoot = mkDefault false;
  hardware.bluetooth.settings.General.Enable = mkDefault "Source,Sink,Media,Socket";
  hardware.bluetooth.settings.General.Experimental = mkDefault true;

  environment.systemPackages = with pkgs; [
    blueman
    bluez
    bluez-tools
  ];

  boot.kernelModules = [
    "btusb"
    "bluetooth"
  ];
}
