{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  arxiv-mcp-server = pkgs.callPackage ./arxiv-mcp-server { };
  baibot = pkgs.callPackage ./baibot { };
  blender-mcp = pkgs.callPackage ./blender-mcp { };
  bulk-rename = pkgs.callPackage ./bulk-rename { };
  cppman = pkgs.callPackage ./cppman { };
  fetcher-mcp = pkgs.callPackage ./fetcher-mcp { };
  freecad-mcp = pkgs.callPackage ./freecad-mcp { };
  mcpo = pkgs.callPackage ./mcpo { };
  pass2bw = pkgs.callPackage ./pass2bw { };
  pyman = pkgs.callPackage ./pyman { };
  quicknote = pkgs.callPackage ./quicknote { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };
  trelis-gitingest-mcp = pkgs.callPackage ./trelis-gitingest-mcp { };

  # marker-pdf = pkgs.callPackage ./marker-pdf { }; # FIXME
}
