{ config, lib, ... }:

let
  cfg = config.wayland.windowManager.hyprland;

  inherit (lib) mkIf;
in
{
  programs.hyprlock = mkIf cfg.enable {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = true;
      };

      animations.enabled = false;

      label = {
        text = "$TIME";
        font_size = 100;
        position = "0, 50";
        halign = "center";
        valign = "center";
      };

      input-field = {
        size = "200, 50";
        position = "0, -80";
        dots_center = true;
        fade_on_empty = false;
        outline_thickness = 3;
      };
    };
  };
}
