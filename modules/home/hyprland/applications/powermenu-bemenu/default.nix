{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.powermenu.default;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "powermenu-bemenu") {
    home.packages = [ (import ./powermenu-bemenu.nix { inherit config pkgs; }) ];
  };
}
