pkgs:

{
  "GitHub" = {
    url = "https://github.com/search?q={searchTerms}";
    icon = "https://github.com/favicon.ico";
    alias = "@gh";
  };

  "Home Manager Options" = {
    url = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@hm";
  };

  "Nix Packages" = {
    url = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@np";
  };

  "NixOS Options" = {
    url = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@no";
  };

  "NixOS Wiki" = {
    url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
    icon = "https://wiki.nixos.org/favicon.png";
    alias = "@nw";
  };

  "Nixpkgs Issues" = {
    url = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue%20state%3Aopen%20{searchTerms}";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@ni";
  };

  "NuschtOS Search" = {
    url = "https://search.xn--nschtos-n2a.de/?query={searchTerms}";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@nu";
  };

  "Wikiless" = {
    url = "https://wikiless.metastem.su/wiki/{searchTerms}";
    icon = "https://wikiless.metastem.su/wikiless-favicon.ico";
    alias = "@wiki";
  };

  "YouTube" = {
    url = "https://www.youtube.com/results?search_query={searchTerms}";
    icon = "https://www.youtube.com/favicon.ico";
    alias = "@yt";
  };

  "ProtonDB" = {
    url = "https://www.protondb.com/search?q={searchTerms}";
    icon = "https://www.protondb.com/favicon.ico";
    alias = "@pdb";
  };

  "SteamDB" = {
    url = "https://steamdb.info/search/?a=all&q={searchTerms}";
    icon = "https://steamdb.info/favicon.ico";
    alias = "@stdb";
  };

  "keyforsteam" = {
    url = "https://www.keyforsteam.de/katalog/?search_name={searchTerms}";
    icon = "https://www.keyforsteam.de/favicon.ico";
    alias = "@k4s";
  };

  "HowLongToBeat" = {
    url = "https://howlongtobeat.com/?q={searchTerms}";
    icon = "https://howlongtobeat.com/favicon.ico";
    alias = "@hltb";
  };
}
