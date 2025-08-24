{ config, lib, ... }:

let
  cfg = config.stylix;
  target = cfg.targets.hyprland;

  inherit (lib)
    mkIf
    mkOption
    types
    ;
in
{
  options.stylix.targets.hyprland = {
    gaps = mkOption {
      type = types.int;
      default = 0;
      description = "Window gaps in pixels.";
    };
    radius = mkOption {
      type = types.int;
      default = 0;
      description = "Window corner radius in pixels.";
    };
  };

  config = mkIf (cfg.enable && target.enable) {
    wayland.windowManager.hyprland = {
      settings = {
        general = {
          gaps_in = target.gaps / 2;
          gaps_out = target.gaps;
        };
        decoration = {
          rounding = target.radius;
        };
      };
    };
  };
}
