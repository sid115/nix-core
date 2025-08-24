pkgs:

{
  github = {
    url = "https://github.com/search?q={searchTerms}";
    icon = "https://github.com/favicon.ico";
    alias = "@gh";
  };

  home-manager-options = {
    url = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@hm";
  };

  nixpkgs = {
    url = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@np";
  };

  nixos-options = {
    url = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@no";
  };

  nixos-wiki = {
    url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
    icon = "https://wiki.nixos.org/favicon.png";
    alias = "@nw";
  };

  noogle = {
    url = "https://noogle.dev/q?term={searchTerms}";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@nf";
  };

  nuschtos = {
    url = "https://search.xn--nschtos-n2a.de/?query={searchTerms}";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@nu";
  };

  nixpkgs-issues = {
    url = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue%20state%3Aopen%20{searchTerms}";
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    alias = "@ni";
  };

  wikiless = {
    url = "https://wikiless.metastem.su/wiki/{searchTerms}";
    icon = "https://wikiless.metastem.su/wikiless-favicon.ico";
    alias = "@wiki";
  };

  youtube = {
    url = "https://www.youtube.com/results?search_query={searchTerms}";
    icon = "https://www.youtube.com/favicon.ico";
    alias = "@yt";
  };

  protondb = {
    url = "https://www.protondb.com/search?q={searchTerms}";
    icon = "https://www.protondb.com/favicon.ico";
    alias = "@pdb";
  };

  steamdb = {
    url = "https://steamdb.info/search/?a=all&q={searchTerms}";
    icon = "https://steamdb.info/favicon.ico";
    alias = "@stdb";
  };

  keyforsteam = {
    url = "https://www.keyforsteam.de/katalog/?search_name={searchTerms}";
    icon = "https://www.keyforsteam.de/favicon.ico";
    alias = "@k4s";
  };

  howlongtobeat = {
    url = "https://howlongtobeat.com/?q={searchTerms}";
    icon = "https://howlongtobeat.com/favicon.ico";
    alias = "@hltb";
  };
}
