{
  config,
  lib,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.terminal.default;

  inherit (lib) mkIf;
in
{
  imports = [ ../../../kitty ];

  config = mkIf (cfg.enable && app == "kitty") {
    programs.kitty = {
      enable = true;
    };
  };
}
