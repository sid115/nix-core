{ pkgs, lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  programs.hyprland.enable = mkDefault true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services = {
    login = {
      enableGnomeKeyring = true;
    };
    hyprlock = { };
  };

  services.udisks2.enable = mkDefault true;

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
