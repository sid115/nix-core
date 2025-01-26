{
  config,
  lib,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.networksettings.default;

  inherit (lib) mkIf;
in
{
  imports = [ ../../../networkmanager-dmenu ];

  config = mkIf (cfg.enable && app == "networkmanager_dmenu") {
    programs.networkmanager-dmenu = {
      enable = true;
      config.dmenu.dmenu_command = "bemenu";
    };
  };
}
