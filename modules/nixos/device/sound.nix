{ lib, pkgs, ... }:

let
  inherit (lib) mkDefault;
in
{
  services.pulseaudio.enable = mkDefault false;

  security.rtkit.enable = mkDefault true;

  environment.systemPackages = with pkgs; [
    pulseaudioFull
  ];
}
