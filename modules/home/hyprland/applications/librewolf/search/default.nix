{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.librewolf;
  engines = import ./engines.nix pkgs;

  urlRegex = "^(http|https|ftp)://";
  isUrl = s: (match urlRegex s) != null;

  transformEngine =
    engine:
    let
      every_day = 24 * 60 * 60 * 1000;
    in
    {
      urls = [ { template = engine.url; } ];
      icon = engine.icon;
      updateInterval = if (isUrl engine.icon) then every_day else null;
      definedAliases = optional (engine ? alias) engine.alias;
    };

  transformedEngines = mapAttrs' (name: engine: {
    name = name;
    value = transformEngine engine;
  }) engines;

  inherit (lib)
    listToAttrs
    mapAttrs
    mapAttrs'
    mkOption
    optional
    types
    ;
  inherit (lib.strings) match;
in
{
  options.programs.librewolf = {
    searchEngines = mkOption {
      type = types.listOf types.str;
      default = [
        "GitHub"
        "Home Manager Options"
        "Nix Packages"
        "NixOS Options"
        "NixOS Wiki"
        "Nixpkgs Issues"
        "NuschtOS Search"
        "Wikiless"
        "YouTube"
      ];
      example = [
        "GitHub"
        "Home Manager Options"
        "HowLongToBeat"
        "Nix Packages"
        "NixOS Options"
        "NixOS Wiki"
        "Nixpkgs Issues"
        "NuschtOS Search"
        "ProtonDB"
        "SteamDB"
        "Wikiless"
        "YouTube"
        "keyforsteam"
      ];
      description = "Additional search engines for LibreWolf.";
    };
  };

  config.programs.librewolf = {
    profiles.default.search.engines = mapAttrs (_: name: transformedEngines.${name}) (
      listToAttrs (
        map (name: {
          name = name;
          value = name;
        }) cfg.searchEngines
      )
    );
  };
}
