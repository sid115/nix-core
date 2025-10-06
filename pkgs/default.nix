{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  arxiv-mcp-server = pkgs.callPackage ./arxiv-mcp-server { };
  baibot = pkgs.callPackage ./baibot { };
  blender-mcp = pkgs.callPackage ./blender-mcp { };
  cppman = pkgs.callPackage ./cppman { };
  fetcher-mcp = pkgs.callPackage ./fetcher-mcp { };
  marker-pdf = pkgs.callPackage ./marker-pdf { };
  mcpo = pkgs.callPackage ./mcpo { };
  pass2bw = pkgs.callPackage ./pass2bw { };
  pyman = pkgs.callPackage ./pyman { };
  quicknote = pkgs.callPackage ./quicknote { };
  qwen-code = pkgs.callPackage ./qwen-code { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };
  trelis-gitingest-mcp = pkgs.callPackage ./trelis-gitingest-mcp { };
  # visual-paradigm-community = pkgs.callPackage ./visual-paradigm-community { }; # FIXME
}
