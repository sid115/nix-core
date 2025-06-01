{
  config,
  lib,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.browser.default;

  desktop = "librewolf.desktop";
  mimeTypes = [
    "text/html"
    "text/xml"
    "application/xhtml+xml"
    "application/vnd.mozilla.xul+xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ];
  associations =
    let
      genMimeAssociations = import ../genMimeAssociations.nix;
    in
    genMimeAssociations desktop mimeTypes;

  inherit (lib) mkIf;
in
{
  imports = [ ../../../librewolf ];

  config = mkIf (cfg.enable && app == "librewolf") {
    programs.librewolf = {
      enable = true;
    };

    xdg.mimeApps = {
      associations.added = associations;
      defaultApplications = associations;
    };
  };
}
