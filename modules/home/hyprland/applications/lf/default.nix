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
  imports = [ ../../../lf ];

  config = mkIf (cfg.enable && app == "lf") {
    programs.lf = {
      enable = true;
    };

    # special workspace (scratchpad) for lf
    wayland.windowManager.hyprland.extraConfig = ''
      workspace = special:lf, on-created-empty:${cfg.applications.terminal.default} -T lf -e lf
    '';
  };
}
