{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.librewolf;

  inherit (lib) mkDefault mkIf;
in
{
  imports = [ ./search ];

  config = {
    programs.librewolf = {
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

    home.sessionVariables = mkIf cfg.enable (
      with cfg;
      {
        DEFAULT_BROWSER = "${package}/bin/librewolf";
        BROWSER = "${package}/bin/librewolf";
      }
    );
  };
}
