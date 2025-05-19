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
      urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
      icon = "https://github.com/favicon.ico";
      updateInterval = every_day;
      definedAliases = [ "@gh" ];
    };

    "Home Manager Options" = {
      urls = [ { template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master"; } ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@hm" ];
    };

    "Nix Packages" = {
      urls = [ { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; } ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@np" ];
    };

    "NixOS Options" = {
      urls = [ { template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}"; } ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@no" ];
    };

    "NixOS Wiki" = {
      urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
      icon = "https://wiki.nixos.org/favicon.png";
      updateInterval = every_day;
      definedAliases = [ "@nw" ];
    };

    "Nixpkgs Issues" = {
      urls = [ { template = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue%20state%3Aopen%20{searchTerms}"; } ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@ni" ];
    };

    "NuschtOS Search" = {
      urls = [ { template = "https://search.xn--nschtos-n2a.de/?query={searchTerms}"; } ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@nu" ];
    };

    "Startpage" = {
      # TODO: replace with Searx when instance on portuus.de is ready
      urls = [ { template = "https://www.startpage.com/do/dsearch?q={searchTerms}"; } ];
      icon = "https://www.startpage.com/sp/cdn/favicons/favicon--default.ico";
      updateInterval = every_day;
    };

    "Wikiless" = {
      urls = [ { template = "https://wikiless.metastem.su/wiki/{searchTerms}"; } ];
      icon = "https://wikiless.metastem.su/wikiless-favicon.ico";
      updateInterval = every_day;
      definedAliases = [ "@wiki" ];
    };

    youtube = {
      urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
      icon = "https://www.youtube.com/favicon.ico";
      updateInterval = every_day;
      definedAliases = [ "@yt" ];
    };

    protondb = {
      urls = [ { template = "https://www.protondb.com/search?q={searchTerms}"; } ];
      icon = "https://www.protondb.com/favicon.ico";
      updateInterval = every_day;
      definedAliases = [ "@pdb" ];
    };

    steamdb = {
      urls = [ { template = "https://steamdb.info/search/?a=all&q={searchTerms}"; } ];
      icon = "https://steamdb.info/favicon.ico";
      updateInterval = every_day;
      definedAliases = [ "@stdb" ];
    };

    keyforsteam = {
      urls = [ { template = "https://www.keyforsteam.de/katalog/?search_name={searchTerms}"; } ];
      icon = "https://www.keyforsteam.de/favicon.ico";
      updateInterval = every_day;
      definedAliases = [ "@k4s" ];
    };

    howlongtobeat = {
      urls = [ { template = "https://howlongtobeat.com/?q={searchTerms}"; } ];
      icon = "https://howlongtobeat.com/favicon.ico";
      updateInterval = every_day;
      definedAliases = [ "@hltb" ];
    };

    # engines below are disabled
    bing.metaData.hidden = true;
    ddg.metaData.hidden = true;
    google.metaData.hidden = true;
  };
}
