{ config, lib, ... }:

let
  desktop = config.services.xrdp.desktop;

  inherit (lib) mkIf;
in
{
  config = mkIf (desktop == "plasma") {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasmax11";

    services.xrdp.defaultWindowManager = "startplasma-x11";
  };
}
