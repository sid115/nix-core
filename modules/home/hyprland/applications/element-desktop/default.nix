{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.matrix-client.default;

  inherit (lib) mkDefault mkIf;
in
{
  config = mkIf (cfg.enable && app == "element-desktop") {
    # FIXME: screen sharing does not work
    programs.element-desktop = {
      enable = true;
      settings = {
        # Use Chromium for screen sharing
        default_theme = mkDefault "dark";
      };
    };
  };
}
