{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.bluetoothsettings.default;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "dmenu-bluetooth") {
    home.packages = with pkgs; [ dmenu-bluetooth ];

    home.sessionVariables = {
      DMENU_BLUETOOTH_LAUNCHER = cfg.applications.applauncher.default or "bemenu";
    };
  };
}
