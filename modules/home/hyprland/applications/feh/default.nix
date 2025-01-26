{ config, lib, ... }:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.imageviewer.default;
  desktop = "feh.desktop";
  mimeTypes = [
    "image/gif"
    "image/heic"
    "image/jpeg"
    "image/jpg"
    "image/pjpeg"
    "image/png"
    "image/tiff"
    "image/webp"
    "image/x-bmp"
    "image/x-pcx"
    "image/x-png"
    "image/x-portable-anymap"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-tga"
    "image/x-xbitmap"
  ];
  associations =
    let
      genMimeAssociations = import ../genMimeAssociations.nix;
    in
    genMimeAssociations desktop mimeTypes;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "feh") {
    programs.feh = {
      enable = true;
    };

    xdg.mimeApps = {
      defaultApplications = associations;
      associations.added = associations;
    };
  };
}
