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

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "librewolf") {
    programs.librewolf = {
      enable = true;
      policies.Homepage.StartPage = lib.mkDefault "previous-session";
      profiles.default = {
        extensions = import ./extensions.nix { inherit inputs pkgs; };
        search = import ./search.nix { inherit pkgs; };
        settings = import ./settings.nix;
        userChrome = builtins.readFile ./userChrome.css;
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
