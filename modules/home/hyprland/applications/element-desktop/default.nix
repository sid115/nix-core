{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.matrix-client.default;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "element-desktop") {
    # FIXME: screen sharing does not work
    # home.packages = [ pkgs.element-desktop ];
  };
}
