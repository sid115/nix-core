{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.office.default;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "libreoffice") {
    home.packages = [ pkgs.libreoffice ];

    # TODO: set Tools > Options > Application Colors > Automatic = Dark
  };
}
