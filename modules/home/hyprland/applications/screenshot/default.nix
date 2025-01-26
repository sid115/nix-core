{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.screenshotter.default;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "screenshot") {
    home.packages = [ (import ./screenshot.nix { inherit config pkgs; }) ];
  };
}
