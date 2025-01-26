{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  desktop = "chromium-browser.desktop";

  inherit (lib)
    mkDefault
    mkIf
    ;
in
{
  config = mkIf cfg.enable {
    programs.chromium = {
      enable = mkDefault true;
      package = mkDefault pkgs.ungoogled-chromium;
    };

    # Never open chromium by default
    xdg.mimeApps.associations.removed = mkIf config.programs.chromium.enable {
      "application/pdf" = desktop;
      "application/rdf+xml" = desktop;
      "application/rss+xml" = desktop;
      "application/xhtml+xml" = desktop;
      "application/xhtml_xml" = desktop;
      "application/xml" = desktop;
      "image/gif" = desktop;
      "image/jpeg" = desktop;
      "image/png" = desktop;
      "image/webp" = desktop;
      "text/html" = desktop;
      "text/xml" = desktop;
      "x-scheme-handler/http" = desktop;
      "x-scheme-handler/https" = desktop;
      "x-scheme-handler/webcal" = desktop;
      "x-scheme-handler/mailto" = desktop;
      "x-scheme-handler/about" = desktop;
      "x-scheme-handler/unknown" = desktop;
    };
  };
}
