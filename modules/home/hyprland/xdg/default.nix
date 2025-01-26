{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  portal = pkgs.xdg-desktop-portal-hyprland;

  inherit (lib) mkDefault mkIf;
in
{
  config.xdg = mkIf cfg.enable {
    enable = mkDefault true;
    mime.enable = mkDefault true;
    mimeApps.enable = mkDefault true;
    userDirs = {
      enable = mkDefault true;
      createDirectories = mkDefault true;
    };
    portal.enable = mkDefault true;
    portal.extraPortals = [ portal ];
    portal.configPackages = [ portal ];
  };
}
