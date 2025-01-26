{ pkgs, ... }:

let
  every_day = 24 * 60 * 60 * 1000;
in
{
  force = true;
  default = "Startpage";
  privateDefault = "Startpage";
  order = [ "Startpage" ];
  engines = {

    "GitHub" = {
      urls = [
        {
          template = "https://github.com/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      #iconUpdateURL = "";
      #updateInterval = every_day;
      definedAliases = [ "@gh" ];
    };

    "Home Manager Options" = {
      urls = [
        {
          template = "https://home-manager-options.extranix.com/";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@hm" ];
    };

    "Nix Packages" = {
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@np" ];
    };

    "NixOS Options" = {
      urls = [
        {
          template = "https://search.nixos.org/options";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@no" ];
    };

    "NixOS Wiki" = {
      urls = [
        {
          template = "https://wiki.nixos.org/index.php";
          params = [
            {
              name = "search";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      iconUpdateURL = "https://wiki.nixos.org/favicon.png";
      updateInterval = every_day;
      definedAliases = [ "@nw" ];
    };

    "NuschtOS Search" = {
      urls = [ { template = "https://search.xn--nschtos-n2a.de/?query={searchTerms}"; } ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@nu" ];
    };

    "Startpage" = {
      # TODO: replace with Searx when instance on portuus.de is ready
      urls = [ { template = "https://www.startpage.com/do/dsearch?q={searchTerms}"; } ];
      iconUpdateURL = "https://www.startpage.com/sp/cdn/favicons/favicon--default.ico";
      updateInterval = every_day;
    };

    "Wikiless" = {
      urls = [ { template = "https://wikiless.metastem.su/wiki/{searchTerms}"; } ];
      iconUpdateURL = "https://wikiless.metastem.su/wikiless-favicon.ico";
      updateInterval = every_day;
      definedAliases = [ "@wiki" ];
    };

    "YouTube" = {
      urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
      iconUpdateURL = "https://www.youtube.com/favicon.ico";
      updateInterval = every_day;
      definedAliases = [ "@yt" ];
    };

    # engines below are disabled
    "Bing".metaData.hidden = true;
    "DuckDuckGo".metaData.hidden = true;
    "Google".metaData.hidden = true;
  };
}
