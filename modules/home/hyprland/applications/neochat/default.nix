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
  config = mkIf (cfg.enable && app == "neochat") {
    home.packages = [ pkgs.kdePackages.neochat ];

    nixpkgs.config.permittedInsecurePackages = [
      "olm-3.2.16"
    ];
  };
}
