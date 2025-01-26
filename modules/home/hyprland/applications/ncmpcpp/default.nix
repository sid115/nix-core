{ config, lib, ... }:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.musicplayer.default;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "ncmpcpp") {
    programs = {
      ncmpcpp = {
        enable = true;
      };
    };
    services = {
      mpd = {
        enable = true;
      };
    };
  };
}
