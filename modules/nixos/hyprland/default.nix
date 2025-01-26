{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  programs.hyprland.enable = mkDefault true;
  security.pam.services.hyprlock = { };
  services.udisks2.enable = mkDefault true;
}
