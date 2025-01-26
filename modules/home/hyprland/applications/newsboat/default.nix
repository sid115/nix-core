{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.rssreader.default;
  reloadTime = "${toString config.programs.newsboat.reloadTime}";
  newsboat-reload = (import ./newsboat-reload.nix { inherit config pkgs; });

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "newsboat") {
    programs.newsboat = {
      enable = true;
      extraConfig = builtins.readFile ./extra-config;
    };

    home.packages = [ newsboat-reload ]; # newsboat's waybar module executes newsboat-reload on click

    # Automatically reload newsboat on timer
    systemd.user = {
      timers.newsboat-reload = {
        Unit.Description = "Reload newsboat every ${reloadTime} minutes";

        Timer.OnBootSec = "10sec";
        Timer.OnUnitActiveSec = "${reloadTime}min";
        Timer.Unit = "newsboat-reload.service";

        Install.WantedBy = [ "timers.target" ];
      };

      services.newsboat-reload = {
        Unit.Description = "Reload newsboat";

        Service.Type = "oneshot";
        Service.ExecStart = "${newsboat-reload}/bin/newsboat-reload";

        Install.WantedBy = [ "multi-user.target" ];
      };
    };
  };
}
