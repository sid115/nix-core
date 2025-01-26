{ config, lib, ... }:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.pdfviewer.default;
  desktop = "org.pwmt.zathura.desktop";
  mimeTypes = [
    "application/pdf"
  ];
  associations =
    let
      genMimeAssociations = import ../genMimeAssociations.nix;
    in
    genMimeAssociations desktop mimeTypes;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "zathura") {
    programs.zathura = {
      enable = true;
      options = {
        guiptions = "none";
        selection-clipboard = "clipboard";
      };
    };

    xdg.mimeApps = {
      defaultApplications = associations;
      associations.added = associations;
    };
  };
}
