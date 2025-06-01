{
  inputs,
  config,
  lib,
  pkgs,
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

  inherit (lib) mkDefault mkIf;
in
{
  imports = [ ./search ];

  config = mkIf (cfg.enable && app == "librewolf") {
    programs.librewolf = {
      enable = true;
      policies.Homepage.StartPage = mkDefault "previous-session";
      profiles.default = {
        extensions.packages = import ./extensions.nix { inherit inputs pkgs; };
        settings = import ./settings.nix;
        search = {
          force = true;
          default = "Startpage";
          privateDefault = "Startpage";
          order = [ "Startpage" ];
          engines = {
            Startpage = {
              urls = [ { template = "https://www.startpage.com/do/dsearch?q={searchTerms}"; } ];
              icon = "https://www.startpage.com/sp/cdn/favicons/favicon--default.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
            };
            # engines below are disabled
            bing.metaData.hidden = true;
            ddg.metaData.hidden = true;
            google.metaData.hidden = true;
          };
        };
      };
    };

    home.sessionVariables = with config.programs.librewolf; {
      DEFAULT_BROWSER = "${package}/bin/librewolf";
      BROWSER = "${package}/bin/librewolf";
    };

    xdg.mimeApps = {
      associations.added = associations;
      defaultApplications = associations;
    };
  };
}
