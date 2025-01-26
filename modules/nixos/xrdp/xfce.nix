{ config, lib, ... }:

let
  desktop = config.services.xrdp.desktop;

  inherit (lib) mkIf;
in
{
  config = mkIf (desktop == "xfce") {
    services.xserver.displayManager.lightdm.enable = true;
    services.displayManager.defaultSession = "xfce";
    services.xserver.desktopManager.xfce.enable = true;

    services.xrdp.defaultWindowManager = "xfce4-session";
  };
}
