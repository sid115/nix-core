{ config, lib, ... }:
let
  howlongtobeat = {
    name = "howlongtobeat";
    urls = [ { template = "https://howlongtobeat.com/?q={searchTerms}"; } ];
    icon = "https://howlongtobeat.com/favicon.ico";
    updateInterval = 1000;
    definedAliases = [ "@hltb" ];
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

  #  engineList = [
  #  item1
  #  howlongtobeat
  #]; # builtins.listToAttrs [ item1 item3 ];

  inherit (lib) types mkOption;
in
{
  options = {
    list1 = mkOption {
      type = types.listOf types.attrs;
      default = null;
      description = "A list of items.";
    };
    programs.librewolf.searchEngines = mkOption {
      type = types.attrsOf types.any;
      default = { };
      description = "A set of search engines for the browser.";
    };
  };

  config = {
    programs.librewolf.searchEngines = [
      howlongtobeat
      keyforsteam
      protondb
    ];
    programs.librewolf.profiles.default.search.engines = lib.listToAttrs (
      map (item: {
        name = item.name;
        value = item;
      }) config.programs.librewolf.searchEngines
    );
  };
}
