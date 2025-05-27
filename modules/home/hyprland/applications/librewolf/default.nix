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
  every_day = 24 * 60 * 60 * 1000; 
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

howlongtobeat = {
    name = "howlongtobeat";
    urls = [ { template = "https://howlongtobeat.com/?q={searchTerms}"; } ];
    icon = "https://howlongtobeat.com/favicon.ico";
    updateInterval = 1000;
    definedAliases = [ "@hltb" ];
  };
protondb = {
      name = "protondb";
      urls = [ { template = "https://www.protondb.com/search?q={searchTerms}"; } ];
      icon = "https://www.protondb.com/favicon.ico";
      updateInterval = every_day;
      definedAliases = [ "@pdb" ];
    };


  inherit (lib) mkDefault mkOption types mkIf;
in
{
options = {
    programs.librewolf.searchEngines = mkOption {
      type = types.listOf types.attrs;
      default = null;
      description = "A set of search engines for the browser.";
    };
  };

  config = mkIf (cfg.enable && app == "librewolf") {
    programs.librewolf = {
      enable = true;
      searchEngines = [
      protondb
      howlongtobeat
      ];
      policies.Homepage.StartPage = mkDefault "previous-session";
      profiles.default = {
        extensions.packages = import ./extensions.nix { inherit inputs pkgs; };
        #search = import ./search.nix { inherit pkgs; };
        search.engines = lib.listToAttrs (
        map (item: {
        name = item.name;
        value = item;
      }) config.programs.librewolf.searchEngines
    );
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
