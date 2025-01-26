{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.torrent-client.default;
  desktop = "org.qbittorrent.qBittorrent.desktop";
  mimeTypes = [
    "application/x-bittorrent"
    "x-scheme-handler/magnet"
  ];
  associations =
    let
      genMimeAssociations = import ../genMimeAssociations.nix;
    in
    genMimeAssociations desktop mimeTypes;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "qbittorrent") {
    home.packages = [ pkgs.qbittorrent ];
    # TODO: automatically apply dark theme

    xdg.mimeApps = {
      defaultApplications = associations;
      associations.added = associations;
    };
  };
}
