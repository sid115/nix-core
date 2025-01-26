{ config, lib, ... }:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.videoplayer.default;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "mpv") {
    programs.mpv = {
      enable = true;
    };
  };
}
