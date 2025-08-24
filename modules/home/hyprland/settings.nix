{ config, lib, ... }:

let
  cfg = config.wayland.windowManager.hyprland;

  inherit (lib) mkDefault;
in
{
  # Do not add binds here. Use `./binds/default.nix` instead.
  "$mod" = cfg.modifier;

  windowrule = [
    "center, floating:1, not class:^(Gimp)$, not class:^(Steam)$"
    "float, title:^Open File"
    "float, title:^Save File"
    "noborder, onworkspace:w[t1]"

    # https://wiki.hyprland.org/Useful-Utilities/Screen-Sharing/#xwayland
    "opacity 0.0 override, class:^(xwaylandvideobridge)$"
    "noanim, class:^(xwaylandvideobridge)$"
    "noinitialfocus, class:^(xwaylandvideobridge)$"
    "maxsize 1 1, class:^(xwaylandvideobridge)$"
    "noblur, class:^(xwaylandvideobridge)$"
  ];

  # Layouts
  general.layout = mkDefault "master";
  master = {
    mfact = mkDefault 0.5;
    new_status = mkDefault "master";
    new_on_top = mkDefault true;
  };

  input.kb_layout = mkDefault "de";

  xwayland = {
    force_zero_scaling = mkDefault true;
  };

  misc = {
    disable_hyprland_logo = mkDefault true;
    force_default_wallpaper = mkDefault 0;
  };

  # Styling
  animations.enabled = mkDefault false;
  decoration = {
    blur.enabled = mkDefault false;
    shadow.enabled = mkDefault false;
  };
  general = {
    resize_on_border = mkDefault true;
    border_size = mkDefault 2;
  };
}
