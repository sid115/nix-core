{
  config,
  lib,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.password-manager.default;

  inherit (lib) mkIf;
in
{
  imports = [ ../../../password-manager ];

  config = mkIf (cfg.enable && app == "passwordmanager") {
    programs.passwordManager = {
      enable = true;
      wayland = true;
    };
  };
}
