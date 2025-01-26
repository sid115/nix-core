{
  config,
  lib,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.applauncher.default;

  inherit (lib) mkIf;
in
{
  imports = [ ../../../bemenu ];

  config = mkIf (cfg.enable && app == "bemenu") {
    programs.bemenu = {
      enable = true;
    };
  };
}
