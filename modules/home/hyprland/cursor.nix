{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkForce;
in
{
  home.pointerCursor = {
    name = mkForce "Bibata-Original-Ice";
    size = mkForce 24;
    package = mkForce pkgs.bibata-cursors;
  };

  home.packages = [ pkgs.hyprcursor ];

  home.sessionVariables = {
    HYPRCURSOR_THEME = config.home.pointerCursor.name;
    HYPRCURSOR_SIZE = toString config.home.pointerCursor.size;
  };

  # wayland.windowManager.hyprland.cursor.no_hardware_cursors = true;
}
