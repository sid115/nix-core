{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;

  hyprland = import ./hyprland.nix;
  mediakeys = import ./mediakeys.nix { inherit pkgs; };
  windows = import ./windows.nix;
  workspaces = import ./workspaces.nix;

  binds = builtins.concatLists [
    hyprland
    mediakeys
    windows
    workspaces
  ];

  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        bind = binds;
        bindm = (import ./mouse.nix);
      };
    };
  };
}
