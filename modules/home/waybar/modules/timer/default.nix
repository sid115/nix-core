# custom/timer
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.waybar;
  timer = pkgs.writeShellScriptBin "timer" (builtins.readFile ./timer.sh);

  inherit (lib) mkDefault mkIf;
in
{
  config = mkIf cfg.enable {
    programs.waybar.settings.mainBar."custom/timer" = {
      exec = mkDefault "${timer}/bin/timer print";
      # `interval` is not needed since timer script will update the status bar
      format = mkDefault "{}";
      hide-empty-text = mkDefault true; # disable module when output is empty
      signal = mkDefault 11;
      on-click = mkDefault "${timer}/bin/timer stop";
    };

    home.packages = [ timer ]; # Add an additional check if the widget is enabled? Currently, the waybar module installs this package regardless of the config.
  };
}
