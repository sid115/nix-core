{
  config,
  lib,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.filemanager.default;

  inherit (lib) mkIf;
in
{
  imports = [ ../../../lf ];

  config = mkIf (cfg.enable && app == "lf") {
    programs.lf = {
      enable = true;
    };
  };
}
