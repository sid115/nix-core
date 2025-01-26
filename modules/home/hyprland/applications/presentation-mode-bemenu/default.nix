{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.presentation-mode.default;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "presentation-mode-bemenu") {
    home.packages = [
      (pkgs.writeShellScriptBin "presentation-mode-bemenu" (
        builtins.readFile ./presentation-mode-bemenu.sh
      ))
    ];
  };
}
