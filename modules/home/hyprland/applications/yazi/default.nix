{
  config,
  lib,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.filemanager.default;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "yazi") {
    programs.yazi = {
      enable = true;
      enableZshIntegration = config.programs.zsh.enable;
    };
  };
}
